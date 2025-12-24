{**
 * templates/frontend/pages/privacy.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme privacy page matching about page layout
 *}
{include file="frontend/components/header.tpl" pageTitle="manager.setup.privacyStatement"}

<div class="page page_privacy ems-about-page">
	<div class="about-container">
		<div class="about-content">
			<h1 class="about-title">
				{translate key="manager.setup.privacyStatement"}
			</h1>
			{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="privacyStatement" sectionTitleKey="manager.setup.privacyStatement"}

			<div class="about-body">
				{$privacyStatement}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}

