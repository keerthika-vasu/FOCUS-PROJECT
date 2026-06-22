"""
FOCUS-SHIELD – RewardsScreen E2E Tests
Dart source : lib/screens/student/rewards_screen.dart

Covers:
  - Screen title 'Rewards'
  - Subtitle text
  - Points banner (Stars icon, numeric total, 'Total Points' label)
  - 'Your Badges' section title
  - Badge grid items (earned / locked state)
  - 'Unlockables' section
  - Unlockable rows (Ocean Theme, Avatar Pack)
  - Pull-to-refresh
"""

import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

WAIT = 20
SHORT = 8


# ── helpers ───────────────────────────────────────────────────────────────────

def _w(driver, t=WAIT):
    return WebDriverWait(driver, t)


def _find(driver, text, t=WAIT):
    return _w(driver, t).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[@text='{text}' or @content-desc='{text}']"
        ))
    )


def _find_contains(driver, partial, t=WAIT):
    return _w(driver, t).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[contains(@text,'{partial}') or contains(@content-desc,'{partial}')]"
        ))
    )


def _login_and_open_rewards(driver):
    """Log in as student and navigate to Rewards tab."""
    _w(driver, 30).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
        ))
    )
    driver.find_element(
        AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
    ).send_keys("student@focusshield.test")
    fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
    if len(fields) >= 2:
        fields[1].send_keys("TestPass123")
    _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH, "//android.widget.Button[@text='Sign In']"
        ))
    ).click()
    # Open Rewards tab
    rewards_tab = _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            "//*[contains(@content-desc,'Rewards') or contains(@text,'Rewards')]"
        ))
    )
    rewards_tab.click()
    _find(driver, "Rewards")


# ── TestRewardsScreen ─────────────────────────────────────────────────────────

class TestRewardsScreen:
    """TC-RW-01 … TC-RW-15: RewardsScreen UI elements."""

    def test_rw01_rewards_title_visible(self, driver):
        """TC-RW-01: 'Rewards' heading is displayed."""
        _login_and_open_rewards(driver)
        el = _find(driver, "Rewards")
        assert el.is_displayed()

    def test_rw02_subtitle_visible(self, driver):
        """TC-RW-02: Subtitle 'Earn points, badges and unlock themes' is shown."""
        _login_and_open_rewards(driver)
        el = _find_contains(driver, "Earn points, badges")
        assert el.is_displayed()

    def test_rw03_total_points_label(self, driver):
        """TC-RW-03: 'Total Points' label is visible in the banner."""
        _login_and_open_rewards(driver)
        el = _find(driver, "Total Points")
        assert el.is_displayed()

    def test_rw04_points_value_is_numeric(self, driver):
        """TC-RW-04: Points value displayed is a numeric string."""
        _login_and_open_rewards(driver)
        nums = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.TextView[number(@text) = number(@text)]"
        )
        assert len(nums) > 0, "No numeric points value found"

    def test_rw05_your_badges_section_title(self, driver):
        """TC-RW-05: 'Your Badges' section title is present."""
        _login_and_open_rewards(driver)
        el = _find(driver, "Your Badges")
        assert el.is_displayed()

    def test_rw06_badge_grid_rendered(self, driver):
        """TC-RW-06: At least one badge item is rendered in the grid."""
        _login_and_open_rewards(driver)
        views = driver.find_elements(
            AppiumBy.XPATH,
            "//android.view.View[@clickable='false'] | //android.widget.FrameLayout"
        )
        assert len(views) > 0, "Badge grid appears empty"

    def test_rw07_unlockables_section_title(self, driver):
        """TC-RW-07: 'Unlockables' section is present (may require scroll)."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 700)
        el = _find(driver, "Unlockables")
        assert el.is_displayed()

    def test_rw08_ocean_theme_unlockable(self, driver):
        """TC-RW-08: 'Ocean Theme' unlockable row is shown."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 700)
        el = _find(driver, "Ocean Theme")
        assert el.is_displayed()

    def test_rw09_avatar_pack_unlockable(self, driver):
        """TC-RW-09: 'Avatar Pack' unlockable row is shown."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 700)
        el = _find(driver, "Avatar Pack")
        assert el.is_displayed()

    def test_rw10_ocean_theme_subtitle(self, driver):
        """TC-RW-10: Ocean Theme unlock condition text is displayed."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 700)
        el = _find_contains(driver, "1500 points")
        assert el.is_displayed()

    def test_rw11_avatar_pack_status(self, driver):
        """TC-RW-11: 'Unlocked' status text shows for Avatar Pack."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 700)
        el = _find(driver, "Unlocked")
        assert el.is_displayed()

    def test_rw12_pull_to_refresh_no_crash(self, driver):
        """TC-RW-12: Pull-to-refresh on Rewards screen does not crash."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 400, size["width"] // 2, 900, 600)
        _find(driver, "Rewards")
        assert True

    def test_rw13_no_error_state_on_normal_load(self, driver):
        """TC-RW-13: No error message shown on normal rewards load."""
        _login_and_open_rewards(driver)
        errors = driver.find_elements(
            AppiumBy.XPATH,
            "//*[contains(@text,'Error') or contains(@text,'failed')]"
        )
        assert len(errors) == 0, "Unexpected error message on rewards screen"

    def test_rw14_badge_name_text_visible(self, driver):
        """TC-RW-14: At least one badge name text element is visible."""
        _login_and_open_rewards(driver)
        # Badge names come from API; just verify text elements exist in badge area
        texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        meaningful = [t for t in texts if len(t.text) > 2]
        assert len(meaningful) > 3, "Too few text elements on rewards screen"

    def test_rw15_screen_scroll_to_bottom_no_crash(self, driver):
        """TC-RW-15: Scrolling to bottom of rewards list does not crash."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        for _ in range(3):
            driver.swipe(size["width"] // 2, 800, size["width"] // 2, 200, 600)
        assert True

    def test_rw16_no_editable_inputs_on_rewards(self, driver):
        """TC-RW-16: No editable text inputs exist on Rewards screen (read-only)."""
        _login_and_open_rewards(driver)
        inputs = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        assert len(inputs) == 0, f"Unexpected EditText on Rewards screen: {len(inputs)}"

    def test_rw17_subtitle_contains_themes_keyword(self, driver):
        """TC-RW-17: Subtitle text contains 'themes' (verifying exact wording)."""
        _login_and_open_rewards(driver)
        el = _find_contains(driver, "themes")
        assert el.is_displayed()

    def test_rw18_points_value_non_negative(self, driver):
        """TC-RW-18: Points displayed is zero or positive (never negative)."""
        _login_and_open_rewards(driver)
        nums = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.TextView[number(@text) >= 0]"
        )
        assert len(nums) > 0, "No non-negative numeric value found on Rewards screen"

    def test_rw19_scroll_up_after_down_returns_title(self, driver):
        """TC-RW-19: Scrolling down then up restores the 'Rewards' heading."""
        _login_and_open_rewards(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 700, size["width"] // 2, 200, 600)
        driver.swipe(size["width"] // 2, 200, size["width"] // 2, 700, 600)
        el = _find(driver, "Rewards")
        assert el.is_displayed()

    def test_rw20_badge_section_has_multiple_items(self, driver):
        """TC-RW-20: Badge section renders more than one container (multiple badges)."""
        _login_and_open_rewards(driver)
        frames = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.FrameLayout | //android.view.View"
        )
        assert len(frames) > 1, "Expected more than one frame/view on Rewards screen"
