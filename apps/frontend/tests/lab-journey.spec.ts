import { test, expect } from '@playwright/test';

test.describe('Lab Journey', () => {
  test('Lab can login and view schedule', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'alaflabs@testly.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await page.waitForURL('**/lab**');
    await expect(page.locator('text=Lab Dashboard')).toBeVisible();

    // Check for today's bookings
    await page.click('text=Schedule');
    await expect(page.locator('text=Mazen Amir')).toBeVisible(); // Based on seed data
  });
});
