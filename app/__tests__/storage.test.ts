import { loadData, saveData, resetData, STORAGE_KEY } from '../src/logic/storage'
import { demoData } from '../src/logic/demoData'

type KeyValueStore = {
  getItem(key: string): Promise<string | null>
  setItem(key: string, value: string): Promise<void>
  removeItem(key: string): Promise<void>
}

function memoryStore() {
  const store = new Map<string, string>()
  return {
    getItem(key: string): Promise<string | null> {
      return Promise.resolve(store.get(key) ?? null)
    },
    setItem(key: string, value: string): Promise<void> {
      store.set(key, value)
      return Promise.resolve()
    },
    removeItem(key: string): Promise<void> {
      store.delete(key)
      return Promise.resolve()
    },
  }
}

describe('storage', () => {
  test('ohne gespeicherte Daten', async () => {
    const result = await loadData(memoryStore())
    expect(result).toEqual(demoData())
  })

  test('speichern und laden', async () => {
    const store = memoryStore()
    const data = demoData()
    const modifiedData: any = {
      ...data,
      activeId: 'p02',
      likes: ['p02>p01'],
    }
    await saveData(modifiedData, store)
    const loaded = await loadData(store)
    expect(loaded).toEqual(modifiedData)
  })

  test('kaputte Daten', async () => {
    const store = memoryStore()
    await store.setItem(STORAGE_KEY, '{kaputt')
    const result = await loadData(store)
    expect(result).toEqual(demoData())
  })

  test('falsche Version', async () => {
    const store = memoryStore()
    await store.setItem(STORAGE_KEY, JSON.stringify({ version: 2 }))
    const result = await loadData(store)
    expect(result).toEqual(demoData())
  })

  test('Lesefehler', async () => {
    const failingStore: KeyValueStore = {
      getItem(): Promise<string | null> {
        return Promise.reject(new Error('Test error'))
      },
      setItem(): Promise<void> {
        throw new Error('Not supported')
      },
      removeItem(): Promise<void> {
        throw new Error('Not supported')
      },
    }
    const result = await loadData(failingStore)
    expect(result).toEqual(demoData())
  })

  test('zurücksetzen', async () => {
    const store = memoryStore()
    const data = demoData()
    await saveData(data, store)
    const resetResult = await resetData(store)
    expect(resetResult).toEqual(demoData())
    const afterReset = await store.getItem(STORAGE_KEY)
    expect(afterReset).toBeNull()
  })

  test('Standardspeicher', async () => {
    const d = demoData()
    await saveData(d)
    const loaded = await loadData()
    expect(loaded).toEqual(d)
  })
})
