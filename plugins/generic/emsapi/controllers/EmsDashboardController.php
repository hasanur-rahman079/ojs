<?php

/**
 * @file plugins/generic/emsapi/controllers/EmsDashboardController.php
 *
 * Copyright (c) 2024 EmsPub
 * Distributed under the GNU GPL v3.
 *
 * @class EmsDashboardController
 *
 * @brief EMS API controller for dashboard endpoints.
 *        Aggregates submission stats, pending tasks, and user-specific metrics.
 */

namespace APP\plugins\generic\emsapi\controllers;

use APP\facades\Repo;
use APP\submission\Submission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Route;
use PKP\core\PKPBaseController;
use PKP\security\Role;

class EmsDashboardController extends PKPBaseController
{
    /**
     * @copydoc PKPBaseController::getHandlerPath()
     */
    public function getHandlerPath(): string
    {
        return 'ems-api';
    }

    /**
     * @copydoc PKPBaseController::getRouteGroupMiddleware()
     */
    public function getRouteGroupMiddleware(): array
    {
        return [
            'has.user',
            'has.context',
        ];
    }

    /**
     * @copydoc PKPBaseController::isSiteWide()
     */
    public function isSiteWide(): bool
    {
        return false;
    }

    /**
     * @copydoc PKPBaseController::getGroupRoutes()
     */
    public function getGroupRoutes(): void
    {
        Route::middleware([
            self::roleAuthorizer([
                Role::ROLE_ID_MANAGER,
                Role::ROLE_ID_SUB_EDITOR,
                Role::ROLE_ID_ASSISTANT,
                Role::ROLE_ID_AUTHOR,
                Role::ROLE_ID_REVIEWER,
            ]),
        ])->group(function () {
            Route::get('dashboard', $this->dashboard(...))
                ->name('ems.dashboard');

            Route::get('dashboard/queues', $this->queues(...))
                ->name('ems.dashboard.queues');
        });
    }

    /**
     * Get dashboard summary for the current user
     *
     * Returns counts of submissions grouped by status for the
     * currently authenticated user in the current journal context.
     */
    public function dashboard(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $user = $request->user();

        if (!$context || !$user) {
            return response()->json([
                'error' => 'Context or user not resolved',
            ], Response::HTTP_BAD_REQUEST);
        }

        $contextId = (int) $context->getId();
        $userId = (int) $user->getId();

        // Count submissions assigned to this user, grouped by status
        $activeCollector = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->assignedTo([$userId])
            ->filterByStatus([Submission::STATUS_QUEUED]);

        $activeCount = $activeCollector->getCount();

        $publishedCollector = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->assignedTo([$userId])
            ->filterByStatus([Submission::STATUS_PUBLISHED]);

        $publishedCount = $publishedCollector->getCount();

        $declinedCollector = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->assignedTo([$userId])
            ->filterByStatus([Submission::STATUS_DECLINED]);

        $declinedCount = $declinedCollector->getCount();

        // Get recent submissions (last 5)
        $recentSubmissions = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->assignedTo([$userId])
            ->orderBy(\APP\submission\Collector::ORDERBY_DATE_SUBMITTED)
            ->limit(5)
            ->getMany();

        $recent = [];
        foreach ($recentSubmissions as $submission) {
            $publication = $submission->getCurrentPublication();
            $recent[] = [
                'id' => (int) $submission->getId(),
                'title' => $publication ? $publication->getLocalizedTitle() : '',
                'status' => $submission->getData('status'),
                'dateSubmitted' => $submission->getData('dateSubmitted'),
                'stageId' => (int) $submission->getData('stageId'),
            ];
        }

        return response()->json([
            'data' => [
                'submissions' => [
                    'active' => $activeCount,
                    'published' => $publishedCount,
                    'declined' => $declinedCount,
                    'total' => $activeCount + $publishedCount + $declinedCount,
                ],
                'recent' => $recent,
            ],
        ]);
    }

    /**
     * Get pending task queues for the current user
     *
     * Returns submissions grouped by workflow stage where
     * the current user has an active assignment.
     */
    public function queues(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $user = $request->user();

        if (!$context || !$user) {
            return response()->json([
                'error' => 'Context or user not resolved',
            ], Response::HTTP_BAD_REQUEST);
        }

        $contextId = (int) $context->getId();
        $userId = (int) $user->getId();

        // Query active submissions assigned to user
        $submissions = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->assignedTo([$userId])
            ->filterByStatus([Submission::STATUS_QUEUED])
            ->getMany();

        $queues = [
            'submission' => [],
            'review' => [],
            'copyediting' => [],
            'production' => [],
        ];

        $stageNames = [
            WORKFLOW_STAGE_ID_SUBMISSION => 'submission',
            WORKFLOW_STAGE_ID_INTERNAL_REVIEW => 'review',
            WORKFLOW_STAGE_ID_EXTERNAL_REVIEW => 'review',
            WORKFLOW_STAGE_ID_EDITING => 'copyediting',
            WORKFLOW_STAGE_ID_PRODUCTION => 'production',
        ];

        foreach ($submissions as $submission) {
            $stageId = (int) $submission->getData('stageId');
            $bucket = $stageNames[$stageId] ?? 'submission';
            $publication = $submission->getCurrentPublication();

            $queues[$bucket][] = [
                'id' => (int) $submission->getId(),
                'title' => $publication ? $publication->getLocalizedTitle() : '',
                'stageId' => $stageId,
                'dateSubmitted' => $submission->getData('dateSubmitted'),
            ];
        }

        return response()->json([
            'data' => [
                'queues' => $queues,
                'counts' => [
                    'submission' => count($queues['submission']),
                    'review' => count($queues['review']),
                    'copyediting' => count($queues['copyediting']),
                    'production' => count($queues['production']),
                ],
            ],
        ]);
    }
}
