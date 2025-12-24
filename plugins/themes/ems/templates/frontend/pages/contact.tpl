{**
 * templates/frontend/pages/contact.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme contact page - modern and clean design
 *}
{include file="frontend/components/header.tpl" pageTitle="about.contact"}

<div class="page page_contact ems-contact-page">
	<div class="contact-container">
		{* Page Header *}
		<div class="contact-header">
			<h1 class="contact-title">{translate key="about.contact"}</h1>
			<p class="contact-subtitle">Get in touch with us. We're here to help and answer any questions you might have.</p>
			{include file="frontend/components/editLink.tpl" page="management" op="settings" path="context" anchor="contact" sectionTitleKey="about.contact"}
		</div>

		{* Contact Cards Grid *}
		<div class="contact-grid">
			{* Mailing Address Card *}
			{if $mailingAddress}
				<div class="contact-card address-card">
					<div class="card-icon">
						<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M16 18c3.314 0 6-2.686 6-6s-2.686-6-6-6-6 2.686-6 6 2.686 6 6 6z" stroke="#019863" stroke-width="2" fill="none"/>
							<path d="M16 28s10-8 10-14c0-5.523-4.477-10-10-10S6 8.477 6 14c0 6 10 14 10 14z" stroke="#019863" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
						</svg>
					</div>
					<h3 class="card-title">{translate key="common.mailingAddress"}</h3>
					<div class="card-content address-content">
						{$mailingAddress|nl2br|strip_unsafe_html}
					</div>
				</div>
			{/if}

			{* Primary Contact Card *}
			{if $contactTitle || $contactName || $contactAffiliation || $contactPhone || $contactEmail}
				<div class="contact-card primary-contact-card">
					<div class="card-icon">
						<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
							<circle cx="16" cy="10" r="5" stroke="#019863" stroke-width="2" fill="none"/>
							<path d="M6 26c0-5.5 4.5-10 10-10s10 4.5 10 10" stroke="#019863" stroke-width="2" stroke-linecap="round" fill="none"/>
						</svg>
					</div>
					<h3 class="card-title">{translate key="about.contact.principalContact"}</h3>
					<div class="card-content">
						{if $contactName}
							<div class="contact-name">{$contactName|escape}</div>
						{/if}
						{if $contactTitle}
							<div class="contact-role">{$contactTitle|escape}</div>
						{/if}
						{if $contactAffiliation}
							<div class="contact-affiliation">{$contactAffiliation|strip_unsafe_html}</div>
						{/if}
						{if $contactPhone || $contactEmail}
							<div class="contact-details">
								{if $contactPhone}
									<a href="tel:{$contactPhone|escape}" class="contact-detail">
										<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
											<path d="M2 3h3l2 5-2.5 1.5c1 2 2.5 3.5 4.5 4.5L10.5 11l5 2v3c-8 0-13.5-5.5-13.5-13.5z" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
										</svg>
										<span>{$contactPhone|escape}</span>
									</a>
								{/if}
								{if $contactEmail}
									<a href="mailto:{$contactEmail|escape}" class="contact-detail">
										<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
											<rect x="2" y="4" width="16" height="12" rx="2" stroke="#6b7280" stroke-width="1.5" fill="none"/>
											<path d="M2 6l8 5 8-5" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
										</svg>
										<span>{$contactEmail|escape}</span>
									</a>
								{/if}
							</div>
						{/if}
					</div>
				</div>
			{/if}

			{* Technical Support Card *}
			{if $supportName || $supportPhone || $supportEmail}
				<div class="contact-card support-contact-card">
					<div class="card-icon">
						<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
							<circle cx="16" cy="16" r="10" stroke="#019863" stroke-width="2" fill="none"/>
							<path d="M12 16v-2a4 4 0 018 0v2" stroke="#019863" stroke-width="2" stroke-linecap="round" fill="none"/>
							<path d="M10 16h4v6h-4v-6zM18 16h4v6h-4v-6z" stroke="#019863" stroke-width="2" stroke-linejoin="round" fill="none"/>
						</svg>
					</div>
					<h3 class="card-title">{translate key="about.contact.supportContact"}</h3>
					<div class="card-content">
						{if $supportName}
							<div class="contact-name">{$supportName|escape}</div>
						{/if}
						{if $supportPhone || $supportEmail}
							<div class="contact-details">
								{if $supportPhone}
									<a href="tel:{$supportPhone|escape}" class="contact-detail">
										<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
											<path d="M2 3h3l2 5-2.5 1.5c1 2 2.5 3.5 4.5 4.5L10.5 11l5 2v3c-8 0-13.5-5.5-13.5-13.5z" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
										</svg>
										<span>{$supportPhone|escape}</span>
									</a>
								{/if}
								{if $supportEmail}
									<a href="mailto:{$supportEmail|escape}" class="contact-detail">
										<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
											<rect x="2" y="4" width="16" height="12" rx="2" stroke="#6b7280" stroke-width="1.5" fill="none"/>
											<path d="M2 6l8 5 8-5" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
										</svg>
										<span>{$supportEmail|escape}</span>
									</a>
								{/if}
							</div>
						{/if}
					</div>
				</div>
			{/if}
		</div>

		{* Additional Help Section *}
		<div class="contact-help">
			<div class="help-content">
				<svg class="help-icon" width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
					<circle cx="24" cy="24" r="20" stroke="#019863" stroke-width="2" fill="none"/>
					<path d="M18 18a6 6 0 0112 3c0 3-6 4.5-6 7m0 3h.01" stroke="#019863" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
				</svg>
				<h3 class="help-title">Have Questions?</h3>
				<p class="help-description">We're here to help! Feel free to reach out through any of the contact methods above, and we'll get back to you as soon as possible.</p>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}

