import { cn } from '../src/lib/utils';

describe('cn', () => {
  it('deve unir classes corretamente', () => {
    expect(cn('a', 'b')).toBe('a b');
    expect(cn('a', false && 'b', 'c')).toBe('a c');
  });
});
