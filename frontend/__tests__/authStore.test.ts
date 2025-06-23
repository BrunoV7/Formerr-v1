import { useAuthStore } from '../src/store/auth';

describe('useAuthStore', () => {
  it('deve iniciar deslogado', () => {
    const state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBeNull();
    expect(state.token).toBeNull();
  });

  it('deve autenticar e limpar autenticação', () => {
    useAuthStore.getState().setAuth({
      github_id: 1,
      username: 'user',
      name: 'User',
      email: 'user@email.com',
      avatar_url: '',
      github_url: '',
      role: 'user',
      permissions: [],
      limits: {
        max_forms: 1,
        max_submissions_per_month: 1,
        max_questions_per_form: 1,
        max_file_size_mb: 1
      },
      created_at: '',
      user_type: '',
      sprint_version: '',
      is_admin: false
    }, 'token123');
    let state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(true);
    expect(state.token).toBe('token123');
    expect(state.user?.username).toBe('user');

    useAuthStore.getState().clearAuth();
    state = useAuthStore.getState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBeNull();
    expect(state.token).toBeNull();
  });
});
