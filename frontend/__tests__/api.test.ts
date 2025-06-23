import api from '../src/lib/api';
import MockAdapter from 'axios-mock-adapter';

const mock = new MockAdapter(api); // Corrigido para usar a instância correta

describe('api', () => {
  afterEach(() => {
    mock.reset();
  });

  it('deve adicionar Authorization se access_token existir', async () => {
    document.cookie = 'access_token=abc123';
    mock.onGet('/test').reply(200, { ok: true });
    const response = await api.get('/test');
    expect(response.data.ok).toBe(true);
  });
});
