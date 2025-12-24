{**
 * templates/frontend/pages/userRegister.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme registration page matching Figma design
 *}

{assign var="siteContextId" value=PKP\core\PKPApplication::SITE_CONTEXT_ID|intval}

{include file="frontend/components/header.tpl" pageTitle="user.register"}

<div class="page page_register ems-register-page">
	<div class="register-wrapper">
		<div class="register-container">
			<div class="register-card">
				{* Registration Form *}
				<div class="register-content">
					<div class="register-header">
						<h1 class="register-title">Create an Account</h1>
						{if $currentContext}
							<p class="register-subtitle">Please provide the required information to create an account on our submission Manager</p>
						{else}
							<p class="register-subtitle">Join ems.pub to manage your scientific journal submissions and reviews.</p>
						{/if}
					</div>

					{include file="common/formErrors.tpl"}

					<form class="register-form" id="register" method="post" action="{url op="register"}" role="form">
						{* Modern ORCID Section *}
						{if $orcidEnabled}
							<div class="orcid-section">
								<div class="orcid-header">
									<div class="orcid-icon-container">
										<svg class="orcid-icon" width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
											<rect width="48" height="48" rx="24" fill="#A6CE39"/>
											<g transform="translate(8, 8)">
												<text x="16" y="24" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" font-weight="bold" fill="white">iD</text>
												<circle cx="16" cy="10" r="1.5" fill="white"/>
											</g>
										</svg>
									</div>
									<div class="orcid-content">
										<h3 class="orcid-title">Create or Connect your ORCID iD</h3>
										<p class="orcid-description">
											Connect your existing ORCID iD or create a new one to streamline your submissions and ensure proper attribution.
											<a href="{url router="page" page="orcid" op="about"}" class="orcid-link" target="_blank">What is ORCID?</a>
										</p>
									</div>
								</div>
								<div class="orcid-actions">
									{* Hidden ORCID field *}
									<input type="hidden" name="orcid" id="orcid" value="{$orcid|escape}" maxlength="46">
									
									{* ORCID Connect Button *}
									<button type="button" id="connect-orcid-button" class="orcid-connect-btn" onclick="return openORCID();">
										<svg class="orcid-btn-icon" width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
											<rect width="20" height="20" rx="10" fill="#A6CE39"/>
											<g transform="translate(3, 3)">
												<text x="7" y="11" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" font-weight="bold" fill="white">iD</text>
												<circle cx="7" cy="4.5" r="0.7" fill="white"/>
											</g>
										</svg>
										<span>Connect ORCID iD</span>
									</button>
									
									{* Fallback ORCID Registration Link *}
									<a href="https://orcid.org/register" target="_blank" class="orcid-register-link">
										Create ORCID iD
									</a>
									
									{* Optional text *}
									<span class="orcid-optional">Optional</span>
								</div>
							</div>
						{/if}

						{csrf}

						{if $source}
							<input type="hidden" name="source" value="{$source|escape}" />
						{/if}

						{* Two-column layout for name fields *}
						<div class="form-row">
							<div class="form-group">
								<label for="givenName" class="form-label">
									Given name <span class="required">*</span>
								</label>
								<input 
									type="text" 
									id="givenName" 
									name="givenName" 
									class="form-input" 
									placeholder="Enter your given name"
									value="{$givenName|escape}"
									required
								>
							</div>
							
							<div class="form-group">
								<label for="familyName" class="form-label">
									Family name
								</label>
								<input 
									type="text" 
									id="familyName" 
									name="familyName" 
									class="form-input" 
									placeholder="Enter your family name"
									value="{$familyName|escape}"
								>
							</div>
						</div>

						{* Two-column layout for affiliation and country *}
						<div class="form-row">
							<div class="form-group">
								<label for="affiliation" class="form-label">
									Affiliation <span class="required">*</span>
								</label>
								<input 
									type="text" 
									id="affiliation" 
									name="affiliation" 
									class="form-input" 
									placeholder="Enter your affiliation"
									value="{$affiliation|escape}"
									required
								>
							</div>
							
							<div class="form-group">
								<label for="country" class="form-label">
									Country <span class="required">*</span>
								</label>
								<select 
									id="country" 
									name="country" 
									class="form-select"
									required
								>
									<option value="">Select your country</option>
									{html_options options=$countries selected=$country}
								</select>
							</div>
						</div>

						{* Two-column layout for email and username *}
						<div class="form-row">
							<div class="form-group">
								<label for="email" class="form-label">
									Email address <span class="required">*</span>
								</label>
								<input 
									type="email" 
									id="email" 
									name="email" 
									class="form-input" 
									placeholder="Enter your email address"
									value="{$email|escape}"
									required
								>
							</div>
							
							<div class="form-group">
								<label for="username" class="form-label">
									Username <span class="required">*</span>
								</label>
								<input 
									type="text" 
									id="username" 
									name="username" 
									class="form-input" 
									placeholder="Choose a username"
									value="{$username|escape}"
									required
								>
							</div>
						</div>

						{* Two-column layout for passwords *}
						<div class="form-row">
							<div class="form-group">
								<label for="password" class="form-label">
									Password <span class="required">*</span>
								</label>
								<input 
									type="password" 
									id="password" 
									name="password" 
									class="form-input" 
									placeholder="Enter a password"
									required
								>
							</div>
							
							<div class="form-group">
								<label for="password2" class="form-label">
									Repeat password <span class="required">*</span>
								</label>
								<input 
									type="password" 
									id="password2" 
									name="password2" 
									class="form-input" 
									placeholder="Confirm your password"
									required
								>
							</div>
						</div>

						{* Journal selection (if applicable) *}
						{include file="frontend/components/registrationFormContexts.tpl"}

						{* When a user is registering with a specific journal *}
						{if $currentContext}
							{* Allow the user to sign up as a reviewer *}
							{assign var=contextId value=$currentContext->getId()}
							{assign var=userCanRegisterReviewer value=0}
							{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
								{if $userGroup->permitSelfRegistration}
									{assign var=userCanRegisterReviewer value=$userCanRegisterReviewer+1}
								{/if}
							{/foreach}
							{if $userCanRegisterReviewer}
								<div class="form-group checkbox-group reviewer-section">
									{if $userCanRegisterReviewer > 1}
										<label class="form-label">{translate key="user.reviewerPrompt"}</label>
										{capture assign="checkboxLocaleKey"}user.reviewerPrompt.userGroup{/capture}
									{else}
										{capture assign="checkboxLocaleKey"}user.reviewerPrompt.optin{/capture}
									{/if}
									{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
										{if $userGroup->permitSelfRegistration}
											<label class="checkbox-label">
												{assign var="userGroupId" value=$userGroup->id}
												<input type="checkbox" name="reviewerGroup[{$userGroupId}]" value="1"{if in_array($userGroupId, $userGroupIds)} checked="checked"{/if} class="checkbox-input">
												<span class="checkbox-text">{translate key=$checkboxLocaleKey userGroup=$userGroup->getLocalizedData('name')}</span>
											</label>
										{/if}
									{/foreach}
								</div>

								{* Reviewer interests *}
								<div class="form-group">
									<label for="interests" class="form-label">
										{translate key="user.interests"}
									</label>
									<input 
										type="text" 
										id="interests" 
										name="interests" 
										class="form-input" 
										value="{$interests|default:""|escape}"
										placeholder="e.g., Plant Biology, Agricultural Science, Molecular Research..."
									>
								</div>
							{/if}

							{* Privacy consent *}
							{if $currentContext->getData('privacyStatement')}
								<div class="form-group checkbox-group">
									<label class="checkbox-label">
										<input type="checkbox" name="privacyConsent" value="1"{if $privacyConsent} checked="checked"{/if} class="checkbox-input" required>
										{capture assign="privacyUrl"}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="privacy"}{/capture}
										<span class="checkbox-text">{translate key="user.register.form.privacyConsent" privacyUrl=$privacyUrl}</span>
									</label>
								</div>
							{/if}

							{* Email notifications consent *}
							<div class="form-group checkbox-group">
								<label class="checkbox-label">
									<input type="checkbox" name="emailConsent" value="1"{if $emailConsent} checked="checked"{/if} class="checkbox-input">
									<span class="checkbox-text">{translate key="user.register.form.emailConsent"}</span>
								</label>
							</div>
						{else}
							{* When a user is registering for no specific journal, allow them to enter their reviewer interests *}
							<div class="form-group">
								<label for="interests" class="form-label">
									{translate key="user.register.noContextReviewerInterests"}
								</label>
								<input 
									type="text" 
									id="interests" 
									name="interests" 
									class="form-input" 
									value="{$interests|default:""|escape}"
									placeholder="e.g., Plant Biology, Agricultural Science, Molecular Research..."
								>
							</div>

							{* Require the user to agree to the terms of the privacy policy (site-wide) *}
							{if $siteWidePrivacyStatement}
								<div class="form-group checkbox-group">
									<label class="checkbox-label">
										<input type="checkbox" name="privacyConsent[{$siteContextId}]" id="privacyConsent[{$siteContextId}]" value="1"{if $privacyConsent[$siteContextId]} checked="checked"{/if} class="checkbox-input" required>
										{capture assign="privacyUrl"}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="privacy"}{/capture}
										<span class="checkbox-text">{translate key="user.register.form.privacyConsent" privacyUrl=$privacyUrl}</span>
									</label>
								</div>
							{/if}

							{* Email notifications consent *}
							<div class="form-group checkbox-group">
								<label class="checkbox-label">
									<input type="checkbox" name="emailConsent" value="1"{if $emailConsent} checked="checked"{/if} class="checkbox-input">
									<span class="checkbox-text">{translate key="user.register.form.emailConsent"}</span>
								</label>
							</div>
						{/if}

						{* reCAPTCHA *}
						{if $recaptchaPublicKey}
							<div class="form-group">
								<div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey|escape}"></div>
							</div>
						{/if}

						{* altcha spam blocker *}
						{if $altchaEnabled}
							<div class="form-group">
								<altcha-widget challengejson='{$altchaChallenge|@json_encode}' floating></altcha-widget>
							</div>
						{/if}

						{* Register Button *}
						<button type="submit" class="register-button">
							Create Account
						</button>

						{* Login Link *}
						<div class="register-footer">
							<span class="login-text">Already have an account? </span>
							<a href="{url page="login"}" class="login-link">Log in</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}

{* ORCID JavaScript *}
{if $orcidEnabled}
<script type="text/javascript">
function openORCID() {
    console.log('ORCID button clicked');
    
    // Get the ORCID OAuth URL from the form or use a fallback
    var orcidOAuthUrl = '{if $orcidOAuthUrl}{$orcidOAuthUrl|escape}{else}https://orcid.org/oauth/authorize{/if}';
    console.log('ORCID OAuth URL:', orcidOAuthUrl);
    
    // First sign out from ORCID to make sure no other user is logged in
    var orcidUrl = '{if $orcidUrl}{$orcidUrl|escape}{else}https://orcid.org{/if}';
    console.log('ORCID URL:', orcidUrl);
    
    // Check if jQuery is available
    if (typeof $ !== 'undefined') {
        $.ajax({
            url: orcidUrl + '/userStatus.json?logUserOut=true',
            dataType: 'jsonp',
            success: function(result,status,xhr) {
                console.log("ORCID Logged In: " + result.loggedIn);
            },
            error: function (xhr, status, error) {
                console.log(status + ", error: " + error);
            }
        });
    } else {
        console.log('jQuery not available, skipping AJAX call');
    }
    
    // Open ORCID OAuth window
    console.log('Opening ORCID window with URL:', orcidOAuthUrl);
    var oauthWindow = window.open(orcidOAuthUrl, "_blank", "toolbar=no, scrollbars=yes, width=540, height=700, top=500, left=500");
    if (oauthWindow) {
        oauthWindow.opener = self;
        console.log('ORCID window opened successfully');
    } else {
        console.log('Failed to open ORCID window - popup blocked?');
        // Fallback: redirect to ORCID registration
        window.location.href = 'https://orcid.org/register';
    }
    return false;
}

// Alternative simple approach if the above doesn't work
function openORCIDSimple() {
    console.log('Opening simple ORCID registration');
    window.open('https://orcid.org/register', '_blank', 'width=540,height=700,scrollbars=yes,resizable=yes');
    return false;
}

// Debug: Log available variables
console.log('ORCID URL: {$orcidUrl|escape}');
console.log('ORCID OAuth URL: {$orcidOAuthUrl|escape}');
</script>
{else}
<script type="text/javascript">
console.log('ORCID is not enabled');
</script>
{/if}
