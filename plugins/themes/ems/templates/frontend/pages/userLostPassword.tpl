{**
 * templates/frontend/pages/userLostPassword.tpl
 *
 * @brief EMS theme forgot password page matching design
 *}
{include file="frontend/components/header.tpl" pageTitle="user.login.resetPassword"}

<div class="page page_lost_password ems-forgot-password-page">
	<div class="forgot-password-wrapper">
		<div class="forgot-password-container">
			<div class="forgot-password-header">
				<h1 class="forgot-password-title">{translate key="user.login.resetPassword"}</h1>
				<p class="forgot-password-description">{translate key="user.login.resetPasswordInstructions"}</p>
			</div>

			<div class="forgot-password-content">
				<form class="forgot-password-form" id="lostPasswordForm" action="{url page="login" op="requestResetPassword"}" method="post" role="form">
					{csrf}
					
					{if $error}
						<div class="form-error">
							{translate key=$error reason=$reason}
						</div>
					{/if}

					<div class="form-group">
						<label for="email" class="form-label">
							{translate key="user.login.registeredEmail"}
							<span class="required">*</span>
						</label>
						<input 
							type="email" 
							name="email" 
							id="email" 
							class="form-input" 
							value="{$email|escape}" 
							required 
							aria-required="true" 
							autocomplete="email"
							placeholder="Enter your email address"
						>
					</div>

					{* altcha spam blocker *}
					{if $altchaEnabled}
						<div class="form-group">
							<fieldset class="altcha_wrapper">
								<altcha-widget challengejson='{$altchaChallenge|@json_encode}' floating></altcha-widget>
							</fieldset>
						</div>
					{/if}
					
					<div class="form-actions">
						<button class="btn btn-primary btn-reset" type="submit">
							{translate key="user.login.resetPassword"}
						</button>
					</div>

					<div class="form-footer">
						<div class="back-to-login">
							<a href="{url page="login"}" class="back-link">
								<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
								</svg>
								{translate key="user.login"}
							</a>
						</div>
						
                                {if !$disableUserReg}
                                    <div class="register-link">
                                        <span class="register-text">Don't have an account?</span>
                                        <a href="{url page="user" op="register" source=$source}" class="register-link-text">
                                            {translate key="user.login.registerNewAccount"}
                                        </a>
                                    </div>
                                {/if}
					</div>
				</form>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}