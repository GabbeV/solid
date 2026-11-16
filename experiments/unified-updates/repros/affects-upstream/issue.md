# [2.0] affects() on a derived store marks its upstream nested store pending

Calling `affects(list)` on a derived store also makes `isPending(() => person.name)` return true for a separate store used as its input. Nothing writes to or declares `person` affected.

The derived row is a distinct wrapper: `list.people[0] !== person`.

```tsx
const [person] = createStore({ name: "Alice" });
const [list] = createStore(
  () => ({ people: [person] }),
  { people: [] }
);

const markList = action(function* () {
  affects(list);
  yield delay(1000);
});
```

During the action, both the original-person and derived-list pending indicators become true. They both return to false when the action ends.

## Reproduction

https://s.olid.uk/#v1:H4sIAAAAAAAAA5VVTY_bNhD9K1MeCqmQJe8eelAkN9s2BQp0kQApcon2QIsjm1mKJDiUdw1B_72gadlet9skN5Hz5r350nBkXnqFrGS867D1BEYDB4FO7lAAeeMQeu4eCaQnGCx5h7wHqe3gwaIWUm9YxjqpkFg5sp5LnXt6ZiWTvTXOwwi89dLoDI4SGbQOucePgTwDSR8iDUzQOdNDw8goKRZfqGFvGn2icagFujPq7QH2hYonXB-QjW6NJg8CFd9DDUlPJeihX6NLoV6Bxif44EwvCaudkWKVOCSjdhiMhP5v2aMZ_HybQU9peuDtBn3IAe6sTVIYGw0QtT5bdGT0A9SXWSUjaN5jCQ27U7LFhsEUmE5eSpK_9kkOQSYjWDRWYXnmntIMLq4fItmZLjToL0ke6mOtkzngn2AOF-byJ0E7BgOwl6hELFhys1wu4_2J3qEfnIYkgqvQXCC_V1iPI1guQttCkjc_2-eGZdCwzmi_6Hgv1b5hwURc04LQyS4UYVpFKoBqe7OaZ846Y_mGezxPWFVsb87Y9eC90WD0b0q2j_UYSzWnnaTT6p67x9PYhgyrIjqdSezqvZMbqbmCWNh5fkuoyDujNyBF3bBoXByNDVuNH72TepOcJvXYqgjMQ6fTdKqKSLKqCnsp-vtFUK8oBtM36AVYHqfg8_Lha7ov0VDX9THgEqrWCIzSxHu8kHzVKegEr2uV91rtwW_xRe2BtmZQAtbYmh7npPOza1WEUTocwqhNYdri731MtbqzFopVBsK0Q4_a5xv07xSGz1_3f4qkYc4Y37D0h0DApuy4bu65ZSUbm-ORGlaOlwulbNjWe0tlUSD1OW2L2fb2Nl_my4Vr89vbXwTufsRnj05zVZ8WDcmN5oqyl5snO_MXUkefbxU6OXyv4jXivwSvMdcZviQ6MP8PyROuXy_RnFv277imiWWxQJ_QkTSaleyCh2Us7Kwd_iEP79DpAckYkXun-VqhYGXHFWHGPJfqSWpxfS9wd28EstK7Aad_AKNXD2vWBgAA

## Steps

1. Open the reproduction. Both pending indicators start false, and the row identity comparison is false.
2. Click “Mark derived list”.
3. For one second, “Original person pending” incorrectly becomes true alongside “Derived list pending”.

## Expected

Only the derived list should report pending. The original person store should remain not pending throughout: marking a derived output should not propagate a pending declaration back into its input.

## Platform

- Solid: 2.0.0-rc.22
- OS: Linux
- Browser: Chromium
