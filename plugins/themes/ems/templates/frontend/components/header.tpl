{**
 * templates/frontend/components/header.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme header component
 *}

{* Determine whether a logo or title string is being displayed *}
{assign var="showingLogo" value=true}
{if !$displayPageHeaderLogo}
	{assign var="showingLogo" value=false}
{/if}

{capture assign="homeUrl"}
	{url page="index" router=$smarty.const.ROUTE_PAGE}
{/capture}

{* Logo or site title. Only use <h1> heading on the homepage.
	 Otherwise that should go to the page title. *}
{if $requestedOp == 'index'}
	{assign var="siteNameTag" value="h1"}
{else}
	{assign var="siteNameTag" value="div"}
{/if}

{* Determine whether to show a logo of site title *}
{capture assign="brand"}{strip}
	{if $displayPageHeaderLogo}
		<img src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}"
		     {if $displayPageHeaderLogo.altText != ''}alt="{$displayPageHeaderLogo.altText|escape}"
		     {else}alt="{translate key="common.pageHeaderLogo.altText"}"{/if}
				 class="img-fluid">
	{elseif $displayPageHeaderTitle}
		<span class="navbar-logo-text">{$displayPageHeaderTitle|escape}</span>
	{elseif $brandImage}
		<img src="{$brandImage}" alt="{$applicationName|escape}" class="img-fluid">
	{else}
		<div class="ems-logo">
			<div class="logo-icon"></div>
			<span class="logo-text">ems.pub</span>
		</div>
	{/if}
{/strip}{/capture}

<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
{if !$pageTitleTranslated}{capture assign="pageTitleTranslated"}{translate key=$pageTitle}{/capture}{/if}
{include file="frontend/components/headerHead.tpl"}
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

<div class="pkp_structure_page">
	{* Header *}
	<header class="ems-header pkp_structure_head">
		<div class="header-container">
			{* Logo/Brand - Show journal abbreviation in journal context *}
			{if $currentContext}
				{capture assign="journalPublicUrl"}{$currentContext->getData('publisherUrl')}{/capture}
				{if $journalPublicUrl}
					<a class="ems-brand journal-brand" href="{$journalPublicUrl|escape}">
						<span class="journal-name">{$currentContext->getLocalizedAcronym()|escape|default:$currentContext->getLocalizedName()|escape} Submission Portal</span>
					</a>
				{else}
					<a class="ems-brand journal-brand" href="{url journal=$currentContext->getPath() page="index"}">
						<span class="journal-name">{$currentContext->getLocalizedAcronym()|escape|default:$currentContext->getLocalizedName()|escape} Submission Portal</span>
					</a>
				{/if}
		{else}
			<a class="ems-brand" href="{$baseUrl}">
				<img src="{$baseUrl}/plugins/themes/ems/templates/images/ems_brand.png" alt="ems.pub" class="brand-logo">
			</a>
		{/if}

			{* Navigation - Different for journal vs site *}
			<nav class="ems-nav" id="ems-nav">
				{if $currentContext}
					{* Journal Navigation *}
					{capture assign="journalPublicUrl"}{$currentContext->getData('publisherUrl')}{/capture}
					<ul class="nav-links">
						<li class="nav-item">
							{if $journalPublicUrl}
								<a class="nav-link" href="{$journalPublicUrl|escape}">Home</a>
							{else}
								<a class="nav-link" href="{url journal=$currentContext->getPath() page="index"}">Home</a>
							{/if}
						</li>
						<li class="nav-item">
							<a class="nav-link" href="{url page="about" op="submissions"}">Submission Instructions</a>
						</li>
					</ul>
				{else}
					{* Site Navigation *}
					<ul class="nav-links">
						<!-- <li class="nav-item">
							<a class="nav-link" href="#features">About</a>
						</li> -->
						<li class="nav-item">
							<a class="nav-link" href="{$baseUrl}#journals">Journals</a>
						</li>
						<li class="nav-item">
							<a class="nav-link" href="{$baseUrl}#pricing">Pricing</a>
						</li>
						<li class="nav-item">
							<a class="nav-link" href="{$baseUrl}#contact">Contact</a>
						</li>
					</ul>
				{/if}
				
				<div class="header-actions">
					{* Debug: Check what variables are available *}
					{* Current user: {$currentUser|@print_r} *}
					{* Is logged in: {$isUserLoggedIn} *}
					
					{* Manual user menu based on login state *}
					<ul id="navigationUser" class="ems-user-nav pkp_nav_list">
						{if $currentUser}
							{* User is logged in - show dropdown with username *}
							<li class="user-nav-item has-dropdown">
								<a href="#" class="user-dropdown-toggle">
									<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="user-icon">
										<path stroke-linecap="round" stroke-linejoin="round" d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
									</svg>
									<span class="username-text">{$currentUser->getUsername()|escape}</span>
									<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="dropdown-arrow">
										<path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
									</svg>
								</a>
								<ul class="pkp_nav_list">
									<li class="user-nav-item">
										<a href="{url page="submissions"}">
											<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="menu-icon">
												<path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
											</svg>
											<span>Dashboard</span>
										</a>
									</li>
									<li class="user-nav-item">
										<a href="{url page="user" op="profile"}">
											<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="menu-icon">
												<path stroke-linecap="round" stroke-linejoin="round" d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
											</svg>
											<span>Profile</span>
										</a>
									</li>
									<li class="user-nav-item">
										<a href="{url page="login" op="signOut"}">
											<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="menu-icon">
												<path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15m3 0 3-3m0 0-3-3m3 3H9" />
											</svg>
											<span>Logout</span>
										</a>
									</li>
								</ul>
							</li>
						{else}
							{* User is not logged in - show login/register *}
							<li class="user-nav-item">
								<a href="{url page="user" op="register"}">Register</a>
							</li>
							<li class="user-nav-item">
								<a href="{url page="login"}">Login</a>
							</li>
						{/if}
					</ul>
				</div>
			</nav>

			{* Mobile menu toggle *}
			<button class="mobile-menu-toggle" id="mobile-menu-toggle" aria-label="{translate key="common.toggleNavigation"}">
				☰
			</button>
		</div>
	</header>

{* Mobile menu and user dropdown scripts *}
<script>
document.addEventListener('DOMContentLoaded', function() {
	// Mobile menu toggle
	const mobileToggle = document.getElementById('mobile-menu-toggle');
	const nav = document.getElementById('ems-nav');
	
	if (mobileToggle && nav) {
		mobileToggle.addEventListener('click', function() {
			nav.classList.toggle('mobile-open');
		});
	}
	
	// User profile dropdown
	const userToggle = document.getElementById('user-profile-toggle');
	const userDropdown = document.getElementById('user-dropdown');
	
	if (userToggle && userDropdown) {
		userToggle.addEventListener('click', function(e) {
			e.stopPropagation();
			userDropdown.classList.toggle('show');
		});
		
	// Close dropdown when clicking outside
	document.addEventListener('click', function() {
		userDropdown.classList.remove('show');
	});
	}
	
	// Initialize OJS MenuHandler for any navigation menus
	if (typeof $ !== 'undefined' && $.pkp && $.pkp.controllers && $.pkp.controllers.MenuHandler) {
		$('.pkp_nav_list').each(function() {
			$(this).pkpHandler('$.pkp.controllers.MenuHandler');
		});
	}
	
	// Initialize OJS SiteHandler if not already initialized
	if (typeof $ !== 'undefined' && $.pkp && $.pkp.controllers && $.pkp.controllers.SiteHandler) {
		if (!$('body').data('pkpHandler')) {
			$('body').pkpHandler('$.pkp.controllers.SiteHandler', {
				hasSystemNotifications: false
			});
		}
	}
});
</script>