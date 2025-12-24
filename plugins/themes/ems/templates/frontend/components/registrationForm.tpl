{**
 * templates/frontend/components/registrationForm.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme registration form component
 *}

<fieldset class="identity">
	<legend>
		{translate key="user.profile"}
	</legend>
	<div class="fields">
		<div class="form-row">
			<div class="given_name">
				<label class="form-label">
					{translate key="user.givenName"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="text" name="givenName" autocomplete="given-name" id="givenName" class="form-input" placeholder="{translate key='plugins.themes.ems.enterGivenName'}" value="{$givenName|default:""|escape}" maxlength="255" required aria-required="true">
			</div>
			<div class="family_name">
				<label class="form-label">
					{translate key="user.familyName"}
				</label>
				<input type="text" name="familyName" autocomplete="family-name" id="familyName" class="form-input" placeholder="{translate key='plugins.themes.ems.enterFamilyName'}" value="{$familyName|default:""|escape}" maxlength="255">
			</div>
		</div>
		<div class="form-row">
			<div class="affiliation">
				<label class="form-label">
					{translate key="user.affiliation"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="text" name="affiliation" id="affiliation" class="form-input" placeholder="{translate key='plugins.themes.ems.enterAffiliation'}" value="{$affiliation|default:""|escape}" maxlength="255" required aria-required="true">
			</div>
			<div class="country">
				<label class="form-label">
					{translate key="common.country"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<select name="country" id="country" class="form-select" autocomplete="country-name" required aria-required="true">
					<option value="">{translate key="plugins.themes.ems.selectCountry"}</option>
					{html_options options=$countries selected=$country}
				</select>
			</div>
		</div>
	</div>
</fieldset>

<fieldset class="login">
	<legend>
		{translate key="user.login"}
	</legend>
	<div class="fields">
		<div class="form-row">
			<div class="email">
				<label class="form-label">
					{translate key="user.email"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="email" name="email" id="email" class="form-input" placeholder="{translate key='plugins.themes.ems.enterEmail'}" value="{$email|default:""|escape}" maxlength="90" required aria-required="true" autocomplete="email">
			</div>
			<div class="username">
				<label class="form-label">
					{translate key="user.username"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="text" name="username" id="username" class="form-input" placeholder="{translate key='plugins.themes.ems.chooseUsername'}" value="{$username|default:""|escape}" maxlength="32" required aria-required="true" autocomplete="username">
			</div>
		</div>
		<div class="form-row">
			<div class="password">
				<label class="form-label">
					{translate key="user.password"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="password" name="password" id="password" class="form-input" placeholder="{translate key='plugins.themes.ems.enterPassword'}" password="true" maxlength="32" required aria-required="true" autocomplete="new-password">
			</div>
			<div class="password">
				<label class="form-label">
					{translate key="user.register.repeatPassword"}
					<span class="required" aria-hidden="true">*</span>
				</label>
				<input type="password" name="password2" id="password2" class="form-input" placeholder="{translate key='plugins.themes.ems.confirmPassword'}" password="true" maxlength="32" required aria-required="true" autocomplete="new-password">
			</div>
		</div>
	</div>
</fieldset>
