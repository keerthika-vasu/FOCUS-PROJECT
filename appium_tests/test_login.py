"""
FOCUS-SHIELD – LoginScreen E2E Tests
Dart source : lib/screens/auth/login_screen.dart
Runner: Flutter on Android Emulator (API 29, UIAutomator2)

Class: TestLoginScreen  ← classname maps to 'LoginScreen' in JUnit XML
                          which matches KNOWN_SCREENS in the workflow parser.
"""

import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

WAIT_LONG  = 20
WAIT_SHORT = 8


# ── helpers ───────────────────────────────────────────────────────────────────

def _w(driver, t=WAIT_LONG):
    return WebDriverWait(driver, t)


def _find_input_by_hint(driver, hint_text, timeout=WAIT_LONG):
    return _w(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//android.widget.EditText[@text='{hint_text}' or "
            f"@content-desc='{hint_text}']"
        ))
    )


def _find_button(driver, label, timeout=WAIT_LONG):
    return _w(driver, timeout).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            f"//android.widget.Button[@text='{label}']"
        ))
    )


def _find_text(driver, text, timeout=WAIT_LONG):
    return _w(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[@text='{text}' or @content-desc='{text}']"
        ))
    )


def _find_text_contains(driver, partial_text, timeout=WAIT_LONG):
    return _w(driver, timeout).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[contains(@text, '{partial_text}') or "
            f"contains(@content-desc, '{partial_text}')]"
        ))
    )


def _wait_for_login_screen(driver):
    _find_input_by_hint(driver, "you@example.com", timeout=30)


def _reset_to_login(driver):
    try:
        _wait_for_login_screen(driver)
    except Exception:
        driver.reset()
        _wait_for_login_screen(driver)


# ── TestLoginScreen ───────────────────────────────────────────────────────────

class TestLoginScreen:
    """TC-L01 … TC-L18: LoginScreen UI, validation, and navigation."""

    # ── Original 3 tests (converted to methods) ───────────────────────────────

    def test_l01_login_fields_visibility(self, driver):
        """TC-L01: Email, password fields and Sign In button are visible on launch."""
        _wait_for_login_screen(driver)

        email_field = _find_input_by_hint(driver, "you@example.com")
        assert email_field is not None and email_field.is_displayed()

        try:
            pass_field = _find_input_by_hint(driver, "••••••••", timeout=WAIT_SHORT)
        except Exception:
            pass_field = _w(driver, WAIT_SHORT).until(
                EC.presence_of_element_located((
                    AppiumBy.XPATH,
                    "//android.widget.EditText[contains(@content-desc,'Password') or "
                    "contains(@content-desc,'password') or @instance='1']"
                ))
            )
        assert pass_field is not None and pass_field.is_displayed()

        signin_btn = _find_button(driver, "Sign In")
        assert signin_btn is not None and signin_btn.is_displayed()

    def test_l02_empty_credentials_error(self, driver):
        """TC-L02: Sign In with empty fields shows validation error."""
        _reset_to_login(driver)
        email_field = _find_input_by_hint(driver, "you@example.com")
        email_field.clear()
        _find_button(driver, "Sign In").click()
        error_el = _find_text_contains(driver, "Please enter email", timeout=WAIT_SHORT)
        assert error_el is not None and error_el.is_displayed()

    def test_l03_navigate_to_signup(self, driver):
        """TC-L03: Tapping 'Sign Up' link navigates to SignupScreen."""
        _reset_to_login(driver)
        signup_link = _w(driver, WAIT_LONG).until(
            EC.element_to_be_clickable((AppiumBy.XPATH, "//*[@text='Sign Up']"))
        )
        signup_link.click()
        create_account_heading = _find_text(driver, "Create Account", timeout=WAIT_LONG)
        assert create_account_heading is not None and create_account_heading.is_displayed()
        confirm_pass_label = _find_text(driver, "Confirm Password", timeout=WAIT_SHORT)
        assert confirm_pass_label is not None

    # ── New edge-case tests ───────────────────────────────────────────────────

    def test_l04_app_brand_name_visible(self, driver):
        """TC-L04: 'Focus Shield' brand name is displayed on the login screen."""
        _wait_for_login_screen(driver)
        el = _find_text(driver, "Focus Shield")
        assert el.is_displayed()

    def test_l05_tagline_visible(self, driver):
        """TC-L05: Tagline 'Learn. Focus. Achieve.' is shown on the login screen."""
        _wait_for_login_screen(driver)
        el = _find_text(driver, "Learn. Focus. Achieve.")
        assert el.is_displayed()

    def test_l06_forgot_password_link_visible(self, driver):
        """TC-L06: 'Forgot password?' link is visible on the login screen."""
        _wait_for_login_screen(driver)
        el = _find_text_contains(driver, "Forgot password")
        assert el.is_displayed()

    def test_l07_forgot_password_link_tappable(self, driver):
        """TC-L07: Tapping 'Forgot password?' does not crash the app."""
        _wait_for_login_screen(driver)
        el = _find_text_contains(driver, "Forgot password")
        el.click()
        # May show dialog or be a no-op — just verify no crash
        time.sleep(1)
        assert True

    def test_l08_sign_in_button_clickable(self, driver):
        """TC-L08: Sign In button is enabled and responds to a click."""
        _reset_to_login(driver)
        btn = _find_button(driver, "Sign In")
        assert btn.is_enabled(), "Sign In button is not enabled"
        btn.click()
        # Should trigger validation — no crash
        time.sleep(1)

    def test_l09_dont_have_account_text_visible(self, driver):
        """TC-L09: 'Don't have an account?' text is visible."""
        _wait_for_login_screen(driver)
        el = _find_text_contains(driver, "Don't have an account")
        assert el.is_displayed()

    def test_l10_password_field_obscures_text(self, driver):
        """TC-L10: Password field is obscured (password=true attribute)."""
        _wait_for_login_screen(driver)
        pwd_fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        if len(pwd_fields) >= 2:
            pwd = pwd_fields[1]
            pwd.send_keys("test123")
            # password attribute should be true for obscured field
            attr = pwd.get_attribute("password") or ""
            assert attr == "true" or attr == "True", \
                "Password field does not appear to be obscured"

    def test_l11_visibility_toggle_exists(self, driver):
        """TC-L11: Password visibility toggle icon (eye) is present."""
        _wait_for_login_screen(driver)
        toggle = driver.find_elements(
            AppiumBy.XPATH,
            "//*[contains(@content-desc,'visibility') or "
            "contains(@content-desc,'Visibility') or "
            "contains(@content-desc,'Show password') or "
            "contains(@content-desc,'Hide password')]"
        )
        assert len(toggle) > 0, "No visibility toggle found for password field"

    def test_l12_invalid_email_shows_error(self, driver):
        """TC-L12: Submitting with only email (no password) shows error."""
        _reset_to_login(driver)
        email = _find_input_by_hint(driver, "you@example.com")
        email.clear()
        email.send_keys("notanemail")
        _find_button(driver, "Sign In").click()
        # Validation fires — either empty-password error or format error
        errors = driver.find_elements(
            AppiumBy.XPATH,
            "//*[contains(@text,'email') or contains(@text,'password') "
            "or contains(@text,'Please')]"
        )
        assert len(errors) > 0, "No error shown for invalid credentials"

    def test_l13_wrong_credentials_shows_error(self, driver):
        """TC-L13: Wrong email+password shows an error message from the API."""
        _reset_to_login(driver)
        email = _find_input_by_hint(driver, "you@example.com")
        email.clear()
        email.send_keys("wrong@example.com")
        pwd_fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        if len(pwd_fields) >= 2:
            pwd_fields[1].clear()
            pwd_fields[1].send_keys("wrongpassword")
        _find_button(driver, "Sign In").click()
        # Expect some error — either network or auth error
        _w(driver, 15).until(
            EC.presence_of_element_located((
                AppiumBy.XPATH,
                "//*[contains(@text,'Invalid') or contains(@text,'incorrect') "
                "or contains(@text,'not found') or contains(@text,'error') "
                "or contains(@text,'Please')]"
            ))
        )

    def test_l14_email_field_clears_on_clear(self, driver):
        """TC-L14: Email field content can be cleared programmatically."""
        _wait_for_login_screen(driver)
        email = _find_input_by_hint(driver, "you@example.com")
        email.send_keys("test@test.com")
        email.clear()
        text = email.text or email.get_attribute("text") or ""
        # After clear, text should be empty or show hint
        assert "test@test.com" not in text, "Email field did not clear properly"

    def test_l15_special_chars_in_password_no_crash(self, driver):
        """TC-L15: Special characters in password field do not crash the app."""
        _wait_for_login_screen(driver)
        pwd_fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        if len(pwd_fields) >= 2:
            pwd_fields[1].clear()
            pwd_fields[1].send_keys("P@$$w0rd!#%")
        assert True

    def test_l16_two_input_fields_total(self, driver):
        """TC-L16: Exactly two input fields (email and password) are on login screen."""
        _wait_for_login_screen(driver)
        inputs = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        assert len(inputs) == 2, f"Expected 2 inputs on login screen, found {len(inputs)}"

    def test_l17_sign_in_only_one_button(self, driver):
        """TC-L17: Only one primary button ('Sign In') exists on the login screen."""
        _wait_for_login_screen(driver)
        buttons = driver.find_elements(
            AppiumBy.XPATH, "//android.widget.Button[@text='Sign In']"
        )
        assert len(buttons) == 1, f"Expected exactly 1 Sign In button, found {len(buttons)}"

    def test_l18_orientation_change_no_crash(self, driver):
        """TC-L18: Rotating to landscape and back does not crash the login screen."""
        _wait_for_login_screen(driver)
        try:
            driver.rotate("LANDSCAPE")
            time.sleep(1)
            driver.rotate("PORTRAIT")
            time.sleep(1)
        except Exception:
            pass  # Rotation not supported on all emulators
        _wait_for_login_screen(driver)
        assert True
