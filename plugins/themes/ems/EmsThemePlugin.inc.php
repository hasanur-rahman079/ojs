<?php

/**
 * @file plugins/themes/ems/EmsThemePlugin.inc.php
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class EmsThemePlugin
 *
 * @ingroup plugins_themes_ems
 *
 * @brief EMS theme for scholarly publishing workflow management
 */

use APP\core\Application;
use PKP\config\Config;
use PKP\facades\Locale;
use PKP\plugins\ThemePlugin;

class EmsThemePlugin extends ThemePlugin
{
    /**
     * Load the custom styles for our theme
     */
    public function init()
    {
        // Add theme options
        $this->addOption('primaryColour', 'colour', [
            'label' => 'plugins.themes.ems.option.primaryColour.label',
            'description' => 'plugins.themes.ems.option.primaryColour.description',
            'default' => '#0abf96',
        ]);

        $this->addOption('secondaryColour', 'colour', [
            'label' => 'plugins.themes.ems.option.secondaryColour.label',
            'description' => 'plugins.themes.ems.option.secondaryColour.description',
            'default' => '#0a3047',
        ]);

        // Update colours based on theme options
        $additionalLessVariables = [];
        $primaryColour = $this->getOption('primaryColour');
        $secondaryColour = $this->getOption('secondaryColour');

        if ($primaryColour !== '#0abf96') {
            $additionalLessVariables[] = '@primary:' . $primaryColour . ';';
            $additionalLessVariables[] = '
                @primary-light: lighten(@primary, 20%);
                @primary-dark: darken(@primary, 10%);
                @primary-text: darken(@primary, 20%);
            ';
        }

        if ($secondaryColour !== '#0a3047') {
            $additionalLessVariables[] = '@secondary:' . $secondaryColour . ';';
            $additionalLessVariables[] = '
                @secondary-light: lighten(@secondary, 20%);
                @secondary-dark: darken(@secondary, 10%);
            ';
        }

        $this->addScript('app-js', 'libs/app.min.js');

        // Load OJS core JavaScript for dropdown functionality
        $this->addScript('pkp-js', 'js/pkp.min.js');

        // Load theme stylesheet and script
        $this->addStyle('app-css', 'libs/app.min.css');
        $this->addStyle('stylesheet', 'styles/index.less');
        $this->modifyStyle('stylesheet', ['addLessVariables' => join("\n", $additionalLessVariables)]);

        // Styles for HTML galleys
        $this->addStyle('htmlFont', 'styles/htmlGalley.less', ['contexts' => 'htmlGalley']);
        $this->addStyle('htmlGalley', 'templates/plugins/generic/htmlArticleGalley/css/default.css', ['contexts' => 'htmlGalley']);

        // Styles for right to left scripts
        $locale = Locale::getLocale();
        if (Locale::getMetadata($locale)->isRightToLeft()) {
            $this->addStyle('rtl', 'styles/rtl.less');
        }

        // Add navigation menu areas for this theme
        $this->addMenuArea(['primary', 'user']);

        // Get extra data for templates
        HookRegistry::add('TemplateManager::display', [$this, 'loadTemplateData']);
    }

    /**
     * Get the display name of this theme
     */
    public function getDisplayName(): string
    {
        return __('plugins.themes.ems.name');
    }

    /**
     * Get the description of this plugin
     */
    public function getDescription(): string
    {
        return __('plugins.themes.ems.description');
    }

    /**
     * Load custom data for templates
     *
     * @param string $hookName
     * @param array $args [
     *
     *      @option TemplateManager
     *      @option string Template file requested
     *      @option string
     *      @option string
     *      @option string output HTML
     * ]
     */
    public function loadTemplateData($hookName, $args)
    {
        $templateMgr = $args[0];
        $request = Application::get()->getRequest();
        $context = $request->getContext();

        if (!defined('SESSION_DISABLE_INIT')) {
            // Get possible locales
            if ($context) {
                $locales = $context->getSupportedLocaleNames();
            } else {
                $locales = $request->getSite()->getSupportedLocaleNames();
            }

            // Load login form
            $loginUrl = $request->url(null, 'login', 'signIn');
            if (Config::getVar('security', 'force_login_ssl')) {
                $loginUrl = preg_replace('/^http:/u', 'https:', $loginUrl);
            }

            // Check if a custom logo exists, otherwise use the default
            $brandImage = 'templates/images/ems_brand.png';
            if (!file_exists($this->getPluginPath() . '/' . $brandImage)) {
                $brandImage = null; // Will use the text-based logo
            }

            $templateMgr->assign([
                'languageToggleLocales' => $locales,
                'loginUrl' => $loginUrl,
                'brandImage' => $brandImage,
                'primaryColour' => $this->getOption('primaryColour'),
                'secondaryColour' => $this->getOption('secondaryColour'),
            ]);
        }
    }

}
