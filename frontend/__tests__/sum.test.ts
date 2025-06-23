import sum from './sum';

describe('sum', () => {
  it('soma dois números corretamente', () => {
    expect(sum(2, 3)).toBe(5);
    expect(sum(-1, 1)).toBe(0);
  });
});
