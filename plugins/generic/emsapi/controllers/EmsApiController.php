<?php

/**
 * @file plugins/generic/emsapi/controllers/EmsApiController.php
 *
 * @brief Single combined EMS API controller. All EMS routes are defined here.
 *        Used by both the plugin hook and the api/v1/ems-api/index.php entry point.
 */

namespace APP\plugins\generic\emsapi\controllers;

use APP\facades\Repo;
use APP\plugins\generic\emsapi\services\ManuscriptService;
use APP\submission\Submission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Route;
use PKP\core\PKPBaseController;
use PKP\security\Role;

class EmsApiController extends PKPBaseController
{
    protected ManuscriptService $manuscriptService;

    public function __construct()
    {
        $this->manuscriptService = new ManuscriptService();
    }

    public function getHandlerPath(): string
    {
        return 'ems-api';
    }

    public function getRouteGroupMiddleware(): array
    {
        return ['has.user', 'has.context'];
    }

    public function isSiteWide(): bool
    {
        return false;
    }

    public function getGroupRoutes(): void
    {
        // ---- Dashboard ----
        Route::middleware([
            self::roleAuthorizer([
                Role::ROLE_ID_MANAGER, Role::ROLE_ID_SUB_EDITOR,
                Role::ROLE_ID_ASSISTANT, Role::ROLE_ID_AUTHOR, Role::ROLE_ID_REVIEWER,
            ]),
        ])->group(function () {
            Route::get('dashboard', $this->dashboard(...))->name('ems.dashboard');
            Route::get('dashboard/queues', $this->queues(...))->name('ems.dashboard.queues');
        });

        // ---- Manuscripts ----
        Route::middleware([
            self::roleAuthorizer([
                Role::ROLE_ID_MANAGER, Role::ROLE_ID_SUB_EDITOR,
                Role::ROLE_ID_ASSISTANT, Role::ROLE_ID_AUTHOR,
            ]),
        ])->group(function () {
            Route::get('manuscripts', $this->manuscriptIndex(...))->name('ems.manuscripts.index');
            Route::post('manuscripts', $this->manuscriptStore(...))->name('ems.manuscripts.store');
            Route::get('manuscripts/{submissionId}', $this->manuscriptShow(...))->name('ems.manuscripts.show')->whereNumber('submissionId');
            Route::put('manuscripts/{submissionId}', $this->manuscriptUpdate(...))->name('ems.manuscripts.update')->whereNumber('submissionId');
            Route::delete('manuscripts/{submissionId}', $this->manuscriptDestroy(...))->name('ems.manuscripts.destroy')->whereNumber('submissionId');
        });
    }

    // ===== Dashboard =====

    public function dashboard(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $user = $request->user();
        if (!$context || !$user) {
            return response()->json(['error' => 'Context or user not resolved'], Response::HTTP_BAD_REQUEST);
        }

        $contextId = (int) $context->getId();
        $userId = (int) $user->getId();

        $active = Repo::submission()->getCollector()->filterByContextIds([$contextId])->assignedTo([$userId])->filterByStatus([Submission::STATUS_QUEUED])->getCount();
        $published = Repo::submission()->getCollector()->filterByContextIds([$contextId])->assignedTo([$userId])->filterByStatus([Submission::STATUS_PUBLISHED])->getCount();
        $declined = Repo::submission()->getCollector()->filterByContextIds([$contextId])->assignedTo([$userId])->filterByStatus([Submission::STATUS_DECLINED])->getCount();

        $recent = [];
        foreach (Repo::submission()->getCollector()->filterByContextIds([$contextId])->assignedTo([$userId])->orderBy(\APP\submission\Collector::ORDERBY_DATE_SUBMITTED)->limit(5)->getMany() as $s) {
            $p = $s->getCurrentPublication();
            $recent[] = ['id' => (int) $s->getId(), 'title' => $p ? $p->getLocalizedTitle() : '', 'status' => $s->getData('status'), 'dateSubmitted' => $s->getData('dateSubmitted'), 'stageId' => (int) $s->getData('stageId')];
        }

        return response()->json(['data' => ['submissions' => ['active' => $active, 'published' => $published, 'declined' => $declined, 'total' => $active + $published + $declined], 'recent' => $recent]]);
    }

    public function queues(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $user = $request->user();
        if (!$context || !$user) {
            return response()->json(['error' => 'Context or user not resolved'], Response::HTTP_BAD_REQUEST);
        }

        $stageNames = [WORKFLOW_STAGE_ID_SUBMISSION => 'submission', WORKFLOW_STAGE_ID_INTERNAL_REVIEW => 'review', WORKFLOW_STAGE_ID_EXTERNAL_REVIEW => 'review', WORKFLOW_STAGE_ID_EDITING => 'copyediting', WORKFLOW_STAGE_ID_PRODUCTION => 'production'];
        $queues = ['submission' => [], 'review' => [], 'copyediting' => [], 'production' => []];
        $counts = ['submission' => 0, 'review' => 0, 'copyediting' => 0, 'production' => 0];

        foreach (Repo::submission()->getCollector()->filterByContextIds([(int) $context->getId()])->assignedTo([(int) $user->getId()])->filterByStatus([Submission::STATUS_QUEUED])->getMany() as $s) {
            $bucket = $stageNames[(int) $s->getData('stageId')] ?? 'submission';
            $p = $s->getCurrentPublication();
            $queues[$bucket][] = ['id' => (int) $s->getId(), 'title' => $p ? $p->getLocalizedTitle() : '', 'stageId' => (int) $s->getData('stageId'), 'dateSubmitted' => $s->getData('dateSubmitted')];
            $counts[$bucket]++;
        }

        return response()->json(['data' => ['queues' => $queues, 'counts' => $counts]]);
    }

    // ===== Manuscripts =====

    public function manuscriptIndex(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        if (!$context) {
            return response()->json(['error' => 'Context not resolved'], Response::HTTP_BAD_REQUEST);
        }

        $filters = array_filter([
            'status' => $request->query('status'), 'userId' => $request->query('userId'),
            'sectionId' => $request->query('sectionId'), 'searchPhrase' => $request->query('searchPhrase'),
            'page' => $request->query('page', 1), 'perPage' => $request->query('perPage', 30),
            'orderBy' => $request->query('orderBy'), 'orderDir' => $request->query('orderDir', 'DESC'),
        ], fn ($v) => $v !== null);

        $result = $this->manuscriptService->listManuscripts($context, $filters);
        return response()->json(['data' => $result['items'], 'meta' => $result['meta']]);
    }

    public function manuscriptShow(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $id = (int) $this->getParameter('submissionId');
        if (!$context || !$id) {
            return response()->json(['error' => 'Invalid request'], Response::HTTP_BAD_REQUEST);
        }

        $m = $this->manuscriptService->getManuscript($id, (int) $context->getId());
        return $m ? response()->json(['data' => $m]) : response()->json(['error' => 'Manuscript not found'], Response::HTTP_NOT_FOUND);
    }

    public function manuscriptStore(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        if (!$context) {
            return response()->json(['error' => 'Context not resolved'], Response::HTTP_BAD_REQUEST);
        }
        if (empty($request->input('title'))) {
            return response()->json(['error' => 'Title is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
        try {
            $m = $this->manuscriptService->createManuscript($context, [
                'title' => $request->input('title', []), 'abstract' => $request->input('abstract', []),
                'sectionId' => $request->input('sectionId'), 'locale' => $request->input('locale'),
                'saveForLater' => $request->input('saveForLater', false),
            ]);
            return response()->json(['data' => $m], Response::HTTP_CREATED);
        } catch (\Throwable $e) {
            return response()->json(['error' => 'Failed to create manuscript', 'message' => $e->getMessage()], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function manuscriptUpdate(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $id = (int) $this->getParameter('submissionId');
        if (!$context || !$id) {
            return response()->json(['error' => 'Invalid request'], Response::HTTP_BAD_REQUEST);
        }
        $m = $this->manuscriptService->updateManuscript($id, (int) $context->getId(), [
            'locale' => $request->input('locale'), 'title' => $request->input('title'), 'abstract' => $request->input('abstract'),
        ]);
        return $m ? response()->json(['data' => $m]) : response()->json(['error' => 'Manuscript not found'], Response::HTTP_NOT_FOUND);
    }

    public function manuscriptDestroy(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $id = (int) $this->getParameter('submissionId');
        if (!$context || !$id) {
            return response()->json(['error' => 'Invalid request'], Response::HTTP_BAD_REQUEST);
        }
        return $this->manuscriptService->deleteManuscript($id, (int) $context->getId())
            ? response()->json(['data' => ['deleted' => true]])
            : response()->json(['error' => 'Manuscript not found'], Response::HTTP_NOT_FOUND);
    }
}
