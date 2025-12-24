{**
 * templates/frontend/components/authScripts.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme authentication scripts
 *}

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Password strength indicator
    const passwordField = document.getElementById('password');
    const confirmPasswordField = document.getElementById('password2');
    
    if (passwordField) {
        // Create password strength indicator
        const strengthIndicator = document.createElement('div');
        strengthIndicator.className = 'password-strength';
        strengthIndicator.innerHTML = `
            <div class="strength-bar">
                <div class="strength-fill"></div>
            </div>
            <div class="strength-text"></div>
        `;
        passwordField.parentNode.appendChild(strengthIndicator);
        
        passwordField.addEventListener('input', function() {
            const password = this.value;
            const strength = calculatePasswordStrength(password);
            updatePasswordStrength(strengthIndicator, strength);
        });
    }
    
    // Password confirmation validation
    if (confirmPasswordField && passwordField) {
        confirmPasswordField.addEventListener('input', function() {
            const password = passwordField.value;
            const confirmPassword = this.value;
            
            if (confirmPassword && password !== confirmPassword) {
                this.setCustomValidity('Passwords do not match');
                this.classList.add('is-invalid');
            } else {
                this.setCustomValidity('');
                this.classList.remove('is-invalid');
            }
        });
    }
    
    // Reviewer interests toggle
    const reviewerCheckboxes = document.querySelectorAll('.reviewer-checkbox');
    const reviewerInterests = document.getElementById('reviewerInterests');
    
    if (reviewerCheckboxes.length && reviewerInterests) {
        reviewerCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                const anyChecked = Array.from(reviewerCheckboxes).some(cb => cb.checked);
                if (anyChecked) {
                    reviewerInterests.classList.remove('hidden');
                } else {
                    reviewerInterests.classList.add('hidden');
                }
            });
        });
    }
    
    // Form validation enhancement
    const forms = document.querySelectorAll('.ems-login-form, .form-register, .form-reset-password');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.classList.add('is-invalid');
                    isValid = false;
                } else {
                    field.classList.remove('is-invalid');
                }
            });
            
            if (!isValid) {
                e.preventDefault();
                // Scroll to first invalid field
                const firstInvalid = form.querySelector('.is-invalid');
                if (firstInvalid) {
                    firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstInvalid.focus();
                }
            }
        });
    });
    
    // Real-time field validation
    const inputs = document.querySelectorAll('.form-control');
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            if (this.hasAttribute('required') && !this.value.trim()) {
                this.classList.add('is-invalid');
            } else {
                this.classList.remove('is-invalid');
            }
        });
        
        input.addEventListener('input', function() {
            if (this.classList.contains('is-invalid') && this.value.trim()) {
                this.classList.remove('is-invalid');
            }
        });
    });
});

function calculatePasswordStrength(password) {
    let score = 0;
    let feedback = [];
    
    if (password.length >= 8) score += 1;
    else feedback.push('At least 8 characters');
    
    if (/[a-z]/.test(password)) score += 1;
    else feedback.push('Lowercase letter');
    
    if (/[A-Z]/.test(password)) score += 1;
    else feedback.push('Uppercase letter');
    
    if (/[0-9]/.test(password)) score += 1;
    else feedback.push('Number');
    
    if (/[^A-Za-z0-9]/.test(password)) score += 1;
    else feedback.push('Special character');
    
    return {
        score: score,
        feedback: feedback,
        strength: score <= 2 ? 'weak' : score <= 3 ? 'medium' : 'strong'
    };
}

function updatePasswordStrength(indicator, strength) {
    const fill = indicator.querySelector('.strength-fill');
    const text = indicator.querySelector('.strength-text');
    
    // Update bar
    fill.style.width = (strength.score / 5 * 100) + '%';
    fill.className = 'strength-fill strength-' + strength.strength;
    
    // Update text
    if (strength.score === 5) {
        text.textContent = 'Strong password';
        text.className = 'strength-text strength-strong';
    } else if (strength.score >= 3) {
        text.textContent = 'Medium strength';
        text.className = 'strength-text strength-medium';
    } else {
        text.textContent = 'Weak password';
        text.className = 'strength-text strength-weak';
    }
}
</script>

<style>
.password-strength {
    margin-top: @spacer-sm;
}

.strength-bar {
    height: 4px;
    background-color: @border-light;
    border-radius: 2px;
    overflow: hidden;
    margin-bottom: @spacer-sm;
}

.strength-fill {
    height: 100%;
    transition: width 0.3s ease, background-color 0.3s ease;
    border-radius: 2px;
}

.strength-fill.strength-weak {
    background-color: @danger;
}

.strength-fill.strength-medium {
    background-color: @warning;
}

.strength-fill.strength-strong {
    background-color: @success;
}

.strength-text {
    font-size: @font-size-sm;
    font-weight: 500;
}

.strength-text.strength-weak {
    color: @danger;
}

.strength-text.strength-medium {
    color: @warning;
}

.strength-text.strength-strong {
    color: @success;
}

.form-control.is-invalid {
    border-color: @danger;
    box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.15);
}
</style>