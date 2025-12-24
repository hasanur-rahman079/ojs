{**
 * templates/frontend/pages/about.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme about page with centered layout
 *}
{include file="frontend/components/header.tpl" pageTitle="about.aboutContext"}

<div class="page page_about ems-about-page">
	<div class="about-container">
		<div class="about-content">
			<h1 class="about-title">
				{translate key="about.aboutContext"}
			</h1>
			{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="masthead" sectionTitleKey="about.aboutContext"}

			<div class="about-body">
				{$currentContext->getLocalizedData('about')}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}

