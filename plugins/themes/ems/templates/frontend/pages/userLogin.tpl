{**
 * templates/frontend/pages/openidLogin.tpl
 *
 * Copyright (c) 2020 Leibniz Institute for Psychology Information (https://leibniz-psychology.org/)
 * Copyright (c) 2024 Simon Fraser University
 * Copyright (c) 2024 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file LICENSE.
 *
 * EMS Theme: Display the OpenID sign in page with custom styling
 * CUSTOM EMS THEME TEMPLATE OVERRIDE - IF YOU SEE THIS, THE OVERRIDE IS WORKING!
 *}

{include file="frontend/components/header.tpl" pageTitle='plugins.generic.openid.select.provider'}

<div class="page page_openid_login ems-login-page">
	<div class="login-wrapper">
		<div class="login-container">
			<div class="login-card">
				<div class="login-content">
					<div class="login-header">
						<div style="background: #0abf96; color: white; padding: 0.5rem; margin-bottom: 1rem; border-radius: 4px; font-size: 0.875rem; text-align: center;">
							🎨 EMS THEME CUSTOM TEMPLATE ACTIVE - OpenID Plugin Override Working!
						</div>
						<h1 class="login-title">Sign in or register</h1>
						{if $currentContext}
							<p class="login-subtitle">Sign in with your account at {$currentContext->getLocalizedData('name')|escape}</p>
						{else}
							<p class="login-subtitle">Sign in with your account at ems.pub</p>
						{/if}
					</div>

					{if $loginMessage}
						<div class="login-message">
							<p>{translate key=$loginMessage}</p>
						</div>
					{/if}

					{if $openidError}
						<div class="openid-error">
							<div class="error-message">
								{translate key=$errorMsg supportEmail=$supportEmail}
							</div>
							{if $reason}
								<p class="error-reason">{$reason}</p>
							{/if}
						</div>
						{if not $legacyLogin && not $accountDisabled}
							<div class="openid-info">
								{translate key="plugins.generic.openid.error.legacy.link" legacyLoginUrl={url page="login" op="legacyLogin"}}
							</div>
						{/if}
					{/if}

					{* OpenID Provider List *}
					{if $linkList}
						<div class="openid-providers">
							<h3 class="providers-title">Sign in or register with:</h3>
							<div class="providers-list">
								{foreach from=$linkList key=name item=url}
									{if $name == 'custom'}
										<a id="openid-provider-{$name}" href="{$url}" class="provider-btn custom-provider">
											<div class="provider-content">
												{if $customBtnImg}
													<img src="{$customBtnImg}" alt="{$name}" class="provider-icon">
												{else}
													<img src="{$openIDImageURL}{$name}-sign-in.png" alt="{$name}" class="provider-icon">
												{/if}
												<span class="provider-text">
													{if isset($customBtnTxt)}
														{$customBtnTxt}
													{else}
														{translate key="plugins.generic.openid.select.provider.$name"}
													{/if}
												</span>
											</div>
										</a>
									{else}
										<a id="openid-provider-{$name}" href="{$url}" class="provider-btn {$name}-provider">
											<div class="provider-content">
												<img src="{$openIDImageURL}{$name}-sign-in.png" alt="{$name}" class="provider-icon"/>
												<span class="provider-text">{translate key="plugins.generic.openid.select.provider.$name"}</span>
											</div>
										</a>
									{/if}
								{/foreach}
							</div>
						</div>
					{/if}

					{* Legacy Login Form *}
					{if $legacyLogin}
						<div class="legacy-login">
							<div class="login-divider">
								<span class="divider-text">Or sign in with your account</span>
							</div>
							
							<form class="login-form" id="login" method="post" action="{$loginUrl}">
								{csrf}
								<fieldset class="form-fields">
									<div class="form-group">
										<label for="username" class="form-label">
											Username <span class="required">*</span>
										</label>
										<input 
											type="text" 
											name="username" 
											id="username" 
											class="form-input" 
											value="{$username|escape}" 
											placeholder="Enter your username"
											maxlength="32" 
											required 
											aria-required="true"
										>
									</div>
									
									<div class="form-group">
										<label for="password" class="form-label">
											Password <span class="required">*</span>
										</label>
										<input 
											type="password" 
											name="password" 
											id="password" 
											class="form-input" 
											value="{$password|escape}" 
											placeholder="Enter your password"
											maxlength="32" 
											required 
											aria-required="true"
										>
										<div class="password-actions">
											<a href="{url page="login" op="lostPassword"}" class="forgot-link">
												Forgot your password?
											</a>
										</div>
									</div>
									
									<div class="form-group checkbox-group">
										<label class="checkbox-label">
											<input type="checkbox" name="remember" id="remember" value="1" class="checkbox-input">
											<span class="checkbox-text">Keep me logged in</span>
										</label>
									</div>
									
									<button class="login-button" type="submit">
										Log in
									</button>
								</fieldset>
							</form>
						</div>
					{/if}

					{* Register Link *}
					<div class="login-footer">
						<span class="register-text">Don't have an account? </span>
						<a href="{url page="user" op="register"}" class="register-link">Create one here</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
