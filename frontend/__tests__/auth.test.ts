import { getAuthToken, isAuthenticated } from '../src/lib/auth';

describe('auth helpers', () => {
  it('getAuthToken deve retornar null fora do browser', () => {
    expect(getAuthToken()).toBeNull();
  });

  it('isAuthenticated deve retornar false fora do browser', () => {
    expect(isAuthenticated()).toBe(false);
  });
});
