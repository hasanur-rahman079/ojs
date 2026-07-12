<?php

/**
 * @file plugins/generic/emsapi/services/ManuscriptService.php
 *
 * Copyright (c) 2024 EmsPub
 * Distributed under the GNU GPL v3.
 *
 * @class ManuscriptService
 *
 * @brief Business logic layer for manuscript operations.
 *        Wraps OJS Repo calls and transforms data for the EMS API response shape.
 */

namespace APP\plugins\generic\emsapi\services;

use APP\core\Application;
use APP\facades\Repo;
use APP\submission\Submission;
use PKP\context\Context;
use PKP\db\DAORegistry;

class ManuscriptService
{
    /**
     * Transform an OJS Submission object into the EMS manuscript response shape
     */
    public function transformToManuscript(Submission $submission): array
    {
        $publication = $submission->getCurrentPublication();

        $data = [
            'id' => (int) $submission->getId(),
            'status' => $submission->getData('status'),
            'stageId' => (int) $submission->getData('stageId'),
            'dateSubmitted' => $submission->getData('dateSubmitted'),
            'dateLastActivity' => $submission->getData('dateLastActivity'),
            'locale' => $submission->getData('locale'),
            'title' => '',
            'abstract' => '',
            'authors' => [],
            'keywords' => [],
            'sectionId' => null,
            'reviewRound' => null,
        ];

        if ($publication) {
            $data['title'] = $publication->getLocalizedTitle() ?? '';
            $data['abstract'] = $publication->getLocalizedData('abstract') ?? '';
            $data['sectionId'] = (int) $publication->getData('sectionId');
            $data['publicationId'] = (int) $publication->getId();
            $data['version'] = (int) $publication->getData('version');
            $data['datePublished'] = $publication->getData('datePublished');

            // Authors / Contributors
            $authors = $publication->getData('authors');
            if (is_iterable($authors)) {
                foreach ($authors as $author) {
                    $data['authors'][] = [
                        'id' => (int) $author->getId(),
                        'firstName' => $author->getLocalizedGivenName(),
                        'lastName' => $author->getLocalizedFamilyName(),
                        'email' => $author->getData('email'),
                        'affiliation' => implode('; ', $author->getLocalizedAffiliationNames()),
                        'orcid' => $author->getData('orcid'),
                        'primaryContact' => (int) $author->getId() === (int) $publication->getData('primaryContactId'),
                    ];
                }
            }

            // Keywords
            $keywords = $publication->getLocalizedData('keywords');
            if (is_array($keywords)) {
                $data['keywords'] = $keywords;
            }

            // References / Citations (from citations table via CitationDAO)
            $citationDao = DAORegistry::getDAO('CitationDAO'); /** @var \PKP\citation\CitationDAO $citationDao */
            $rawCitations = $citationDao->getRawCitationsByPublicationId($publication->getId());
            $data['references'] = $rawCitations->implode(PHP_EOL);

            // Permissions & Disclosure
            $data['permissions'] = [
                'copyrightHolder' => $publication->getLocalizedData('copyrightHolder') ?? '',
                'copyrightYear' => (int) ($publication->getData('copyrightYear') ?? 0),
                'licenseUrl' => $publication->getData('licenseUrl') ?? '',
            ];

            // Issue Information
            $issueId = $publication->getData('issueId');
            if ($issueId) {
                $issue = Repo::issue()->get((int) $issueId);
                if ($issue) {
                    $data['issue'] = [
                        'id' => (int) $issue->getId(),
                        'title' => $issue->getLocalizedTitle() ?? '',
                        'volume' => (int) $issue->getVolume(),
                        'number' => $issue->getNumber() ?? '',
                        'year' => (int) $issue->getYear(),
                        'published' => (bool) $issue->getPublished(),
                        'datePublished' => $issue->getDatePublished(),
                    ];
                }
            }
        }

        // Current review round
        $reviewRoundDao = DAORegistry::getDAO('ReviewRoundDAO');
        $reviewRound = $reviewRoundDao->getLastReviewRoundBySubmissionId(
            $submission->getId(),
            $submission->getData('stageId')
        );
        if ($reviewRound) {
            $data['reviewRound'] = (int) $reviewRound->getData('round');
            $data['reviewRoundId'] = (int) $reviewRound->getId();
        }

        return $data;
    }

    /**
     * List manuscripts with filters
     */
    public function listManuscripts(Context $context, array $filters = []): array
    {
        $collector = Repo::submission()->getCollector()
            ->filterByContextIds([$context->getId()]);

        // Filter by status
        if (!empty($filters['status'])) {
            $statuses = is_array($filters['status'])
                ? $filters['status']
                : [$filters['status']];
            $collector->filterByStatus($statuses);
        }

        // Filter by user assignment
        if (!empty($filters['userId'])) {
            $collector->assignedTo([(int) $filters['userId']]);
        }

        // Filter by section
        if (!empty($filters['sectionId'])) {
            $collector->filterBySectionIds([(int) $filters['sectionId']]);
        }

        // Search
        if (!empty($filters['searchPhrase'])) {
            $collector->searchPhrase($filters['searchPhrase']);
        }

        // Pagination
        $page = max(1, (int) ($filters['page'] ?? 1));
        $perPage = min(100, max(1, (int) ($filters['perPage'] ?? 30)));
        $offset = ($page - 1) * $perPage;
        $collector->limit($perPage)->offset($offset);

        // Order
        if (!empty($filters['orderBy'])) {
            $collector->orderBy($filters['orderBy'], $filters['orderDir'] ?? 'DESC');
        } else {
            $collector->orderBy(\APP\submission\Collector::ORDERBY_DATE_SUBMITTED, 'DESC');
        }

        $total = $collector->getCount();
        $submissions = $collector->getMany();

        $manuscripts = [];
        foreach ($submissions as $submission) {
            $manuscripts[] = $this->transformToManuscript($submission);
        }

        return [
            'items' => $manuscripts,
            'meta' => [
                'page' => $page,
                'perPage' => $perPage,
                'total' => $total,
                'totalPages' => $perPage > 0 ? (int) ceil($total / $perPage) : 0,
            ],
        ];
    }

    /**
     * Get a single manuscript by ID
     */
    public function getManuscript(int $submissionId, ?int $contextId = null): ?array
    {
        $submission = Repo::submission()->get($submissionId, $contextId);
        if (!$submission) {
            return null;
        }

        $data = $this->transformToManuscript($submission);

        // Add richer detail for single-view: reviewers, files, decisions
        $data['reviewers'] = $this->getManuscriptReviewers($submissionId);
        $data['files'] = $this->getManuscriptFiles($submissionId, $submission);

        return $data;
    }

    /**
     * Create a new submission (manuscript)
     */
    public function createManuscript(Context $context, array $data): array
    {
        $request = Application::get()->getRequest();
        $user = $request->getUser();

        // Create the submission
        $submission = Repo::submission()->newDataObject();
        $submission->setData('contextId', $context->getId());
        $submission->setData('locale', $data['locale'] ?? $context->getSupportedDefaultSubmissionLocale());
        $submission->setData('submissionProgress', ''); // Start as "submitted"

        // Create the publication
        $publication = Repo::publication()->newDataObject();
        $publication->setData('locale', $data['locale'] ?? $context->getSupportedDefaultSubmissionLocale());
        $publication->setData('title', $data['title'] ?? [], $data['locale'] ?? null);
        $publication->setData('abstract', $data['abstract'] ?? [], $data['locale'] ?? null);

        if (!empty($data['sectionId'])) {
            $publication->setData('sectionId', (int) $data['sectionId']);
        }

        // Add the submission + publication
        $submissionId = Repo::submission()->add($submission, $publication, $context);

        // If user is logged in, submit immediately
        if ($user && empty($data['saveForLater'])) {
            $submission = Repo::submission()->get($submissionId);
            if ($submission) {
                Repo::submission()->submit($submission, $context);
            }
        }

        return $this->getManuscript($submissionId, $context->getId());
    }

    /**
     * Update an existing manuscript
     */
    public function updateManuscript(int $submissionId, int $contextId, array $data): ?array
    {
        $submission = Repo::submission()->get($submissionId, $contextId);
        if (!$submission) {
            return null;
        }

        $updateParams = [];

        if (isset($data['locale'])) {
            $updateParams['locale'] = $data['locale'];
        }

        if (!empty($updateParams)) {
            Repo::submission()->edit($submission, $updateParams);
        }

        // Update publication data
        $publication = $submission->getCurrentPublication();
        if ($publication && !empty($data['title'])) {
            $pubParams = [];
            if (!empty($data['title'])) {
                $pubParams['title'] = $data['title'];
            }
            if (!empty($data['abstract'])) {
                $pubParams['abstract'] = $data['abstract'];
            }
            if (!empty($pubParams)) {
                Repo::publication()->edit($publication, $pubParams);
            }
        }

        return $this->getManuscript($submissionId, $contextId);
    }

    /**
     * Delete a manuscript
     */
    public function deleteManuscript(int $submissionId, int $contextId): bool
    {
        $submission = Repo::submission()->get($submissionId, $contextId);
        if (!$submission) {
            return false;
        }

        Repo::submission()->delete($submission);
        return true;
    }

    /**
     * Get reviewers assigned to a manuscript
     */
    private function getManuscriptReviewers(int $submissionId): array
    {
        $reviewAssignments = Repo::reviewAssignment()->getCollector()
            ->filterBySubmissionIds([$submissionId])
            ->getMany();

        $reviewers = [];
        foreach ($reviewAssignments as $assignment) {
            $reviewer = Repo::user()->get($assignment->getReviewerId());
            $reviewers[] = [
                'id' => (int) $assignment->getId(),
                'reviewerId' => (int) $assignment->getReviewerId(),
                'reviewerName' => $reviewer ? $reviewer->getFullName() : '',
                'round' => (int) $assignment->getRound(),
                'stageId' => (int) $assignment->getStageId(),
                'reviewMethod' => (int) $assignment->getReviewMethod(),
                'status' => $this->getReviewAssignmentStatus($assignment),
                'dateAssigned' => $assignment->getDateAssigned(),
                'dateDue' => $assignment->getDateDue(),
                'dateCompleted' => $assignment->getDateCompleted(),
                'recommendation' => (int) $assignment->getRecommendation(),
            ];
        }

        return $reviewers;
    }

    /**
     * Get files attached to a manuscript
     */
    private function getManuscriptFiles(int $submissionId, Submission $submission): array
    {
        $submissionFiles = Repo::submissionFile()
            ->getCollector()
            ->filterBySubmissionIds([$submissionId])
            ->getMany();

        $request = Application::get()->getRequest();
        $context = $request->getContext();

        $files = [];
        foreach ($submissionFiles as $file) {
            $stageId = Repo::submissionFile()->getWorkflowStageId($file);

            // Build download URL using same pattern as OJS core schema map
            $downloadUrl = $request->getDispatcher()->url(
                $request,
                Application::ROUTE_COMPONENT,
                $context ? $context->getData('urlPath') : '',
                'api.file.FileApiHandler',
                'downloadFile',
                null,
                [
                    'fileId' => $file->getData('fileId'),
                    'submissionFileId' => $file->getId(),
                    'submissionId' => $submissionId,
                    'stageId' => $stageId,
                ]
            );

            $files[] = [
                'id' => (int) $file->getId(),
                'filename' => $file->getLocalizedData('name'),
                'fileStage' => (int) $file->getData('fileStage'),
                'genreId' => (int) $file->getData('genreId'),
                'mimetype' => $file->getData('mimetype'),
                'filesize' => (int) $file->getData('filesize'),
                'createdAt' => $file->getData('createdAt'),
                'downloadUrl' => $downloadUrl,
            ];
        }

        return $files;
    }

    /**
     * Get human-readable review assignment status
     */
    private function getReviewAssignmentStatus($assignment): string
    {
        if ($assignment->getCancelled()) {
            return 'cancelled';
        }
        if ($assignment->getDeclined()) {
            return 'declined';
        }
        if ($assignment->getDateCompleted()) {
            return 'completed';
        }
        if ($assignment->getDateConfirmed()) {
            return 'in_progress';
        }
        if ($assignment->getDateNotified()) {
            return 'pending';
        }
        return 'awaiting_response';
    }
}
