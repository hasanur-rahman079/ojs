<?php

/**
 * @file api/v1/ems-api/index.php
 *
 * EMS API — custom Editorial Management System REST API.
 * Handles all /api/v1/ems-api/* requests.
 *
 * Uses OJS as the editorial workflow engine.
 * Never modifies OJS core — this file is the only integration point.
 */

return new \PKP\handler\APIHandler(new \APP\plugins\generic\emsapi\controllers\EmsApiController());
