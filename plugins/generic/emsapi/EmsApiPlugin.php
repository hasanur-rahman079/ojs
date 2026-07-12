<?php

/**
 * @file plugins/generic/emsapi/EmsApiPlugin.php
 *
 * Copyright (c) 2024 EmsPub
 * Distributed under the GNU GPL v3.
 *
 * @class EmsApiPlugin
 *
 * @ingroup plugins_generic_emsapi
 *
 * @brief EMS API Plugin — custom REST API for a Next.js Editorial Management System frontend.
 *        Uses OJS as the workflow engine without modifying core.
 *
 *        The API is served via api/v1/ems-api/index.php (the standard OJS API entry point).
 *        Plugin registration also hooks APIHandler::endpoints::plugin as a secondary path.
 */

namespace APP\plugins\generic\emsapi;

use APP\core\Application;
use PKP\core\APIRouter;
use PKP\plugins\GenericPlugin;
use PKP\plugins\Hook;

class EmsApiPlugin extends GenericPlugin
{
    /**
     * @copydoc Plugin::register()
     *
     * @param null|mixed $mainContextId
     */
    public function register($category, $path, $mainContextId = null)
    {
        $success = parent::register($category, $path, $mainContextId);

        if (Application::isUnderMaintenance()) {
            return true;
        }

        if ($success) {
            Hook::add('APIHandler::endpoints::plugin', function (string $hookName, APIRouter $apiRouter): bool {
                $apiRouter->registerPluginApiControllers([
                    new controllers\EmsApiController(),
                ]);
                return Hook::CONTINUE;
            });
        }

        return $success;
    }

    /**
     * @copydoc Plugin::getName()
     */
    public function getName(): string
    {
        return 'EmsApiPlugin';
    }

    /**
     * @copydoc Plugin::getDisplayName()
     */
    public function getDisplayName(): string
    {
        return 'EMS API Plugin';
    }

    /**
     * @copydoc Plugin::getDescription()
     */
    public function getDescription(): string
    {
        return 'Custom REST API for Editorial Management System. Provides business-oriented API endpoints for a Next.js frontend while using OJS as the workflow engine.';
    }

    /**
     * @copydoc Plugin::isSitePlugin()
     *
     * Site-wide: enable once in admin, works for all journals.
     */
    public function isSitePlugin(): bool
    {
        return true;
    }
}
