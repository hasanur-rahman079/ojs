{**
* templates/frontend/components/loginForm.tpl
*
* Copyright (c) 2024-2025
* Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
*
* @brief EMS theme login form component
*
* @uses $loginUrl string URL to post the login request
* @uses $source string Optional URL to redirect to after successful login
* @uses $username string Username
* @uses $password string Password
* @uses $remember boolean Should logged in cookies be preserved on this computer
* @uses $disableUserReg boolean Can users register for this site?
*}
{if $formType && $formType === "loginPage"}
{assign var=usernameId value="username"}
{assign var=passwordId value="password"}
{assign var=rememberId value="remember"}
{elseif $formType && $formType === "loginModal"}
{assign var=usernameId value="usernameModal"}
{assign var=passwordId value="passwordModal"}
{assign var=rememberId value="rememberModal"}
{/if}

<form class="ems-login-form" method="post" action="{$loginUrl}">
	{csrf}
	<input type="hidden" name="source" value="{$source|strip_unsafe_html|escape}" />

	<div class="form-group">
		<label for="{$usernameId}" class="form-label">
			Username or Email
		</label>
		<input type="text" class="form-control" name="username" id="{$usernameId}" value="{$username|default:""|escape}"
			maxlength="32" autocomplete="username" placeholder="Enter your username or email" required>
	</div>

	<div class="form-group">
		<div class="form-label-row">
			<label for="{$passwordId}" class="form-label">
				Password
			</label>
			<a href="{url page=" login" op="lostPassword" }" class="forgot-password">
				Forgot your password?
			</a>
		</div>
		<input type="password" class="form-control" name="password" id="{$passwordId}"
			value="{$password|default:""|escape}" maxlength="32" autocomplete="current-password"
			placeholder="Enter your password" required>
	</div>

	<div class="form-options">
		<div class="form-check">
			<input type="checkbox" class="form-check-input" name="remember" id="{$rememberId}" value="1" {if
				$remember}checked="checked" {/if}>
			<label for="{$rememberId}" class="form-check-label">
				Keep me logged in
			</label>
		</div>
	</div>

	{* recaptcha spam blocker *}
	{if $recaptchaPublicKey}
	<div class="form-group">
		<fieldset class="recaptcha-wrapper">
			<div class="recaptcha-field">
				<div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey|escape}">
				</div><label for="g-recaptcha-response" style="display:none;" hidden>Recaptcha response</label>
			</div>
		</fieldset>
	</div>
	{/if}

	{* altcha spam blocker *}
	{if $altchaEnabled}
	<fieldset class="altcha-wrapper">
		<div class="altcha-field">
			<altcha-widget challengejson='{$altchaChallenge|@json_encode}' floating></altcha-widget>
		</div>
	</fieldset>
	{/if}

	<div class="form-actions">
		<button class="btn btn-primary btn-block" type="submit">
			Login
		</button>
	</div>
</form>