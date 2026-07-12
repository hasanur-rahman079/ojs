<?php

/**
 * @file plugins/generic/emsapi/controllers/EmsManuscriptController.php
 *
 * Copyright (c) 2024 EmsPub
 * Distributed under the GNU GPL v3.
 *
 * @class EmsManuscriptController
 *
 * @brief EMS API controller for manuscript CRUD endpoints.
 */

namespace APP\plugins\generic\emsapi\controllers;

use APP\plugins\generic\emsapi\services\ManuscriptService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Route;
use PKP\core\PKPBaseController;
use PKP\security\Role;

class EmsManuscriptController extends PKPBaseController
{
    /**  */
    protected ManuscriptService $manuscriptService;

    public function __construct()
    {
        $this->manuscriptService = new ManuscriptService();
    }

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
            ]),
        ])->group(function () {

            Route::get('manuscripts', $this->index(...))
                ->name('ems.manuscripts.index');

            Route::post('manuscripts', $this->store(...))
                ->name('ems.manuscripts.store');

            Route::get('manuscripts/{submissionId}', $this->show(...))
                ->name('ems.manuscripts.show')
                ->whereNumber('submissionId');

            Route::put('manuscripts/{submissionId}', $this->update(...))
                ->name('ems.manuscripts.update')
                ->whereNumber('submissionId');

            Route::delete('manuscripts/{submissionId}', $this->destroy(...))
                ->name('ems.manuscripts.destroy')
                ->whereNumber('submissionId');
        });
    }

    /**
     * GET /api/v1/ems-api/manuscripts
     *
     * List manuscripts with filters:
     *   ?status=1&userId=5&sectionId=3&searchPhrase=climate&page=1&perPage=30
     */
    public function index(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');

        if (!$context) {
            return response()->json([
                'error' => 'Context not resolved',
            ], Response::HTTP_BAD_REQUEST);
        }

        $filters = [
            'status' => $request->query('status'),
            'userId' => $request->query('userId'),
            'sectionId' => $request->query('sectionId'),
            'searchPhrase' => $request->query('searchPhrase'),
            'page' => $request->query('page', 1),
            'perPage' => $request->query('perPage', 30),
            'orderBy' => $request->query('orderBy'),
            'orderDir' => $request->query('orderDir', 'DESC'),
        ];

        // Remove null values
        $filters = array_filter($filters, fn ($v) => $v !== null);

        $result = $this->manuscriptService->listManuscripts($context, $filters);

        return response()->json([
            'data' => $result['items'],
            'meta' => $result['meta'],
        ]);
    }

    /**
     * GET /api/v1/ems-api/manuscripts/{submissionId}
     */
    public function show(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $submissionId = (int) $this->getParameter('submissionId');

        if (!$context || !$submissionId) {
            return response()->json([
                'error' => 'Invalid request',
            ], Response::HTTP_BAD_REQUEST);
        }

        $manuscript = $this->manuscriptService->getManuscript(
            $submissionId,
            (int) $context->getId()
        );

        if (!$manuscript) {
            return response()->json([
                'error' => 'Manuscript not found',
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'data' => $manuscript,
        ]);
    }

    /**
     * POST /api/v1/ems-api/manuscripts
     *
     * Create a new manuscript submission.
     *
     * Request body:
     * {
     *   "title": {"en": "My Paper Title"},
     *   "abstract": {"en": "Abstract text..."},
     *   "sectionId": 1,
     *   "locale": "en",
     *   "saveForLater": false
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');

        if (!$context) {
            return response()->json([
                'error' => 'Context not resolved',
            ], Response::HTTP_BAD_REQUEST);
        }

        $title = $request->input('title', []);
        if (empty($title)) {
            return response()->json([
                'error' => 'Title is required',
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $manuscript = $this->manuscriptService->createManuscript($context, [
                'title' => $request->input('title', []),
                'abstract' => $request->input('abstract', []),
                'sectionId' => $request->input('sectionId'),
                'locale' => $request->input('locale'),
                'saveForLater' => $request->input('saveForLater', false),
            ]);

            return response()->json([
                'data' => $manuscript,
            ], Response::HTTP_CREATED);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => 'Failed to create manuscript',
                'message' => $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * PUT /api/v1/ems-api/manuscripts/{submissionId}
     */
    public function update(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $submissionId = (int) $this->getParameter('submissionId');

        if (!$context || !$submissionId) {
            return response()->json([
                'error' => 'Invalid request',
            ], Response::HTTP_BAD_REQUEST);
        }

        $manuscript = $this->manuscriptService->updateManuscript(
            $submissionId,
            (int) $context->getId(),
            [
                'locale' => $request->input('locale'),
                'title' => $request->input('title'),
                'abstract' => $request->input('abstract'),
            ]
        );

        if (!$manuscript) {
            return response()->json([
                'error' => 'Manuscript not found',
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'data' => $manuscript,
        ]);
    }

    /**
     * DELETE /api/v1/ems-api/manuscripts/{submissionId}
     */
    public function destroy(Request $request): JsonResponse
    {
        $context = $request->attributes->get('context');
        $submissionId = (int) $this->getParameter('submissionId');

        if (!$context || !$submissionId) {
            return response()->json([
                'error' => 'Invalid request',
            ], Response::HTTP_BAD_REQUEST);
        }

        $deleted = $this->manuscriptService->deleteManuscript(
            $submissionId,
            (int) $context->getId()
        );

        if (!$deleted) {
            return response()->json([
                'error' => 'Manuscript not found',
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'data' => ['deleted' => true],
        ]);
    }
}
