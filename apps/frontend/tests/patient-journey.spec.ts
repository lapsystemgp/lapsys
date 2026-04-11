import { test, expect } from '@playwright/test';

test.describe('Patient Journey', () => {
  test('User can search for a lab without logging in', async ({ page }) => {
    await page.goto('/');
    
    // Attempt search
    await page.fill('input[placeholder*="Search for labs"]', 'Blood');
    await page.click('button:has-text("Search")');
    
    // Results should be populated or mocked
    await expect(page.locator('text=Results')).toBeVisible();
  });

  test('User can login and view results', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'patient@testly.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Assuming successful login redirects to /patient
    await page.waitForURL('**/patient**');
    await expect(page.locator('text=Patient Dashboard')).toBeVisible();

    // Navigate to results
    await page.click('text=My Results');
    await expect(page.locator('text=CBC within normal ranges')).toBeVisible(); // Check for seed data summary
  });
});
