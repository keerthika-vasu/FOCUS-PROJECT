"""
Focus Shield – Appium E2E Login Screen Tests
Targets: login_screen.dart, signup_screen.dart
Runner:  Flutter on Android Emulator (API 29, x86_64, UIAutomator2)

Selector strategy for Flutter on Android:
  - TextField (input)   → class=android.widget.EditText, matched by @hint (content-desc fallback)
  - ElevatedButton      → class=android.widget.Button, matched by @text
  - Text / GestureDetector-wrapped Text → class=android.view.View or
    android.widget.TextView, matched by @text or content-desc
  - No @hint attribute in UIAutomator2; use @content-desc or @text for hints.
"""

import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# ──────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────
WAIT_LONG  = 20   # emulator cold-start can be slow
WAIT_SHORT = 8

def _wait(driver, seconds=WAIT_LONG):
    return WebDriverWait(driver, seconds)

def _find_input_by_hint(driver, hint_text, timeout=WAIT_LONG):
    """
    Flutter renders TextField hint as the element's @text when the field is
    empty, on android.widget.EditText. This is the most reliable Flutter selector.
    """
    return _wait(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//android.widget.EditText[@text='{hint_text}' or "
            f"@content-desc='{hint_text}']"
        ))
    )

def _find_button(driver, label, timeout=WAIT_LONG):
    """ElevatedButton → android.widget.Button with @text matching the label."""
    return _wait(driver, timeout).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            f"//android.widget.Button[@text='{label}']"
        ))
    )

def _find_text(driver, text, timeout=WAIT_LONG):
    """
    Finds any visible text element (Text widget, label, error message).
    Covers both TextView and View nodes that Flutter creates.
    """
    return _wait(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[@text='{text}' or @content-desc='{text}']"
        ))
    )

def _find_text_contains(driver, partial_text, timeout=WAIT_LONG):
    """Find element whose @text or @content-desc contains partial_text."""
    return _wait(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[contains(@text, '{partial_text}') or "
            f"contains(@content-desc, '{partial_text}')]"
        ))
    )

def _wait_for_login_screen(driver):
    """Wait until the login screen's email field is visible (app has booted)."""
    _find_input_by_hint(driver, "you@example.com", timeout=30)

# ──────────────────────────────────────────────────────────────
# Tests
# ──────────────────────────────────────────────────────────────

def test_login_fields_visibility(driver):
    """
    TC-L01: Verify that the email field, password field, and Sign In button
    are all visible and accessible on the Login screen after app launch.

    Covers: login_screen.dart → _LabeledField(label='Email', hint='you@example.com')
                                 _LabeledField(label='Password', hint='••••••••')
                                 PrimaryButton(label='Sign In')
    """
    # Wait for app to fully boot and splash to dismiss
    _wait_for_login_screen(driver)

    # ── Email field ──
    # Flutter renders the hint text as @text on android.widget.EditText when empty
    email_field = _find_input_by_hint(driver, "you@example.com")
    assert email_field is not None, "Email field not found on login screen"
    assert email_field.is_displayed(), "Email field is not visible"

    # ── Password field ──
    # Flutter obscured fields: hint is still rendered as @text on EditText
    # Note: actual bullet chars (••••••••) may vary — fall back to content-desc 'Password'
    try:
        pass_field = _find_input_by_hint(driver, "••••••••", timeout=WAIT_SHORT)
    except Exception:
        # Fallback: find by the label text 'Password' nearby or by index
        pass_field = _wait(driver, WAIT_SHORT).until(
            EC.presence_of_element_located((
                AppiumBy.XPATH,
                "//android.widget.EditText[contains(@content-desc,'Password') or "
                "contains(@content-desc,'password') or @instance='1']"
            ))
        )
    assert pass_field is not None, "Password field not found on login screen"
    assert pass_field.is_displayed(), "Password field is not visible"

    # ── Sign In button ──
    signin_btn = _find_button(driver, "Sign In")
    assert signin_btn is not None, "Sign In button not found on login screen"
    assert signin_btn.is_displayed(), "Sign In button is not visible"


def test_login_empty_credentials_error(driver):
    """
    TC-L02: Verify that tapping Sign In with empty fields shows the inline
    error message 'Please enter email and password.'

    Covers: login_screen.dart → _login() validation:
            setState(() => _error = 'Please enter email and password.')
    """
    # Ensure we are on the login screen (reset app state if needed)
    try:
        _wait_for_login_screen(driver)
    except Exception:
        driver.reset()
        _wait_for_login_screen(driver)

    # Clear both fields to ensure they are empty
    email_field = _find_input_by_hint(driver, "you@example.com")
    email_field.clear()

    # Tap Sign In with empty inputs
    signin_btn = _find_button(driver, "Sign In")
    signin_btn.click()

    # The error text from login_screen.dart: 'Please enter email and password.'
    error_el = _find_text_contains(driver, "Please enter email", timeout=WAIT_SHORT)
    assert error_el is not None, "Error message not displayed after empty login attempt"
    assert error_el.is_displayed(), "Error message exists but is not visible"


def test_navigate_to_signup(driver):
    """
    TC-L03: Verify that tapping the 'Sign Up' link from the login screen
    navigates to the Signup screen, which shows 'Create Account' heading
    and a 'Confirm Password' input field.

    Covers: login_screen.dart → GestureDetector → Navigator.push(SignupScreen)
            signup_screen.dart → Text('Create Account')
                                 _Field(label='Confirm Password', hint='••••••••')
    """
    # Ensure we are on login screen
    try:
        _wait_for_login_screen(driver)
    except Exception:
        driver.reset()
        _wait_for_login_screen(driver)

    # Tap the 'Sign Up' text link
    # GestureDetector wrapping a Text('Sign Up') → visible as @text on View/TextView
    signup_link = _wait(driver, WAIT_LONG).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            "//*[@text='Sign Up']"
        ))
    )
    signup_link.click()

    # ── Verify Signup screen loaded ──
    # signup_screen.dart shows Text('Create Account') as a heading
    create_account_heading = _find_text(driver, "Create Account", timeout=WAIT_LONG)
    assert create_account_heading is not None, "'Create Account' heading not found on Signup screen"
    assert create_account_heading.is_displayed(), "'Create Account' heading is not visible"

    # Also verify Confirm Password field is present (label text from _Field widget)
    # The label 'Confirm Password' is rendered as a Text widget → @text attribute
    confirm_pass_label = _find_text(driver, "Confirm Password", timeout=WAIT_SHORT)
    assert confirm_pass_label is not None, "'Confirm Password' label not found on Signup screen"

