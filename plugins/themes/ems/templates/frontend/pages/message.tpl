{**
 * templates/frontend/pages/message.tpl
 *
 * @brief EMS theme message page matching design
 *}
{include file="frontend/components/header.tpl" pageTitle=$pageTitle}

<div class="page page_message ems-message-page">
	<div class="message-wrapper">
		<div class="message-container">
			<div class="message-header">
				<div class="message-icon">
					<svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
						<circle cx="12" cy="12" r="10" stroke="#019863" stroke-width="2"/>
						<path d="M9 12l2 2 4-4" stroke="#019863" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
					</svg>
				</div>
				<h1 class="message-title">
					{translate key=$pageTitle}
				</h1>
			</div>
			
			<div class="message-content">
				<div class="message-text">
					{if $messageTranslated}
						{$messageTranslated}
					{else}
						{translate key=$message}
					{/if}
				</div>
				
				{if $backLink}
					<div class="message-actions">
						<a href="{$backLink}" class="btn btn-primary btn-back">
							{translate key=$backLinkLabel}
						</a>
					</div>
				{/if}
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
