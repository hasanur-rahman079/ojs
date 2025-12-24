{**
 * templates/frontend/pages/indexJournal.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme journal homepage matching Figma design
 *}

{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}

<div class="page_index_journal ems-journal-homepage">
	<div class="journal-content">
		<div class="journal-hero-container">
			<div class="journal-intro">
				<div class="journal-image-wrapper">
					{assign var="journalThumb" value=$currentJournal->getLocalizedData('journalThumbnail')}
					{if $journalThumb}
						<img src="{$baseUrl}/public/journals/{$currentJournal->getId()}/{$journalThumb.uploadName|escape:"url"}" alt="{$journalThumb.altText|escape|default:''}" class="journal-image">
					{elseif $homepageImage}
						<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}" alt="{$homepageImageAltText|escape|default:''}" class="journal-image">
					{else}
						<div class="journal-image-placeholder"></div>
					{/if}
				</div>
				<div class="journal-details">
					<h1 class="journal-title">{$currentJournal->getLocalizedName()|escape}</h1>
					{if $currentJournal->getLocalizedData('about')}
						<div class="journal-description">{$currentJournal->getLocalizedData('about')}</div>
					{else}
						<p class="journal-description">An international, peer-reviewed, open access journal dedicated to publishing high-quality research in all fields of science.</p>
					{/if}
				</div>
			</div>
			
			<div class="journal-actions">
				<a href="{url page="about" op="submissions"}" class="btn btn-submit">Submit Manuscript</a>
				<div class="auth-actions">
					<a href="{url page="user" op="register"}" class="btn btn-register">Register New Account</a>
					<a href="{url page="login"}" class="btn btn-login-dark">Login</a>
				</div>
			</div>
			
			<div class="journal-badges">
				<div class="badge">
					<img src="{$baseUrl}/plugins/themes/ems/templates/images/ithenticate-badge.svg" alt="iThenticate" class="badge-image" />
				</div>
				<div class="badge">
					<img src="{$baseUrl}/plugins/themes/ems/templates/images/crossref_logo.png" alt="Crossref" class="badge-image crossref" />
				</div>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
