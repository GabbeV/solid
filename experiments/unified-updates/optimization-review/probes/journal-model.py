"""Extracted park/filter/remove models; no runtime imports or timing claims."""
import random


def run(journal, deps, prior=None, initialized=True, variant='current'):
    storage = journal[:]  # (identity, subscriber) models an existing graph link.
    count = len(storage)
    saved = prior
    owner_checks = membership_checks = 0
    if variant == 'current':
        if prior is None and initialized:
            for entry in storage:
                owner_checks += 1
                if entry[1] == 'target':
                    saved = []
                    for edge in deps:
                        for inserted in storage[:count]:
                            membership_checks += 1
                            if inserted == edge:
                                break
                        else:
                            saved.append(edge)
                    break
        for index in range(count - 1, -1, -1):
            owner_checks += 1
            if storage[index][1] == 'target':
                count -= 1
                storage[index] = storage[count]
                storage[count] = None
    else:
        original_count = count
        index = 0
        while index < count:
            owner_checks += 1
            if storage[index][1] == 'target':
                count -= 1
                storage[index], storage[count] = storage[count], storage[index]
            else:
                index += 1
        if count != original_count and prior is None and initialized:
            saved = []
            work = set(storage[count:]) if variant == 'set' else None
            for edge in deps:
                if work is not None:
                    membership_checks += 1
                    if edge not in work:
                        saved.append(edge)
                else:
                    for inserted in storage[count:]:
                        membership_checks += 1
                        if inserted == edge:
                            break
                    else:
                        saved.append(edge)
        for index in range(count, original_count):
            storage[index] = None
    assert all(entry is None for entry in storage[count:])
    assert all(entry[1] != 'target' for entry in storage[:count])
    return saved, sorted(storage[:count]), owner_checks, membership_checks


def trial(old, own_count, foreign_count, retained=False, initialized=True, shuffle=False):
    deps = [(index, 'target') for index in range(old + own_count)]
    journal = [(index, 'foreign') for index in range(foreign_count)] + deps[old:]
    if shuffle:
        random.shuffle(journal)
        random.shuffle(deps)
    prior = [('published-frame', 'previous')] if retained else None
    results = [run(journal, deps, prior, initialized, variant)
               for variant in ['current', 'partition', 'set']]
    assert all(result[:2] == results[0][:2] for result in results)
    expected = prior if retained else ([edge for edge in deps if edge not in journal]
                                      if initialized and own_count else None)
    assert results[0][0] == expected
    assert results[0][1] == sorted(entry for entry in journal if entry[1] != 'target')
    return [(result[2], result[3]) for result in results]


random.seed(5)
for old, own, foreign in [(127, 1, 0), (127, 1, 256), (128, 128, 0)]:
    print(f'D={old + own}, J={own + foreign}, I={own}; '
          f'(owner checks, membership probes) current/partition/Set: '
          f'{trial(old, own, foreign)}')
controls = 0
for retained in [False, True]:
    for initialized in [False, True]:
        for _ in range(500):
            trial(*(random.randrange(25) for _ in range(3)),
                  retained=retained, initialized=initialized, shuffle=True)
            controls += 1
        for old, own, foreign in [(4, 0, 5), (0, 0, 0), (0, 8, 4)]:
            trial(old, own, foreign, retained, initialized, shuffle=True)
            controls += 1
print(f'{controls} interleaved/retained/uninitialized identity and clearing controls passed')
