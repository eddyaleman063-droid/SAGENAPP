/**
 * Firebase Admin mock for Cloud Functions tests.
 * Provides in-memory Firestore with transaction support.
 */

class MockFirestore {
  constructor() {
    this._docs = new Map();
  }

  doc(path) {
    const self = this;
    return {
      path,
      id: path.split('/').pop(),
      get() {
        const data = self._docs.get(path);
        return Promise.resolve({
          exists: !!data,
          data: () => data || null,
          id: path.split('/').pop(),
        });
      },
      set(data) {
        self._docs.set(path, { ...data });
        return Promise.resolve();
      },
      update(data) {
        const existing = self._docs.get(path) || {};
        self._docs.set(path, { ...existing, ...data });
        return Promise.resolve();
      },
    };
  }

  collection(name) {
    const self = this;
    const buildQuery = (filters) => ({
      name,
      _filters: filters,
      doc(id) {
        return self.doc(`${name}/${id}`);
      },
      where(field, op, value) {
        return buildQuery([...filters, { field, op, value }]);
      },
      get() {
        const docs = [];
        const prefix = `${name}/`;
        for (const [path, data] of self._docs.entries()) {
          if (!path.startsWith(prefix)) continue;
          const docId = path.slice(prefix.length);
          if (docId.includes('/')) continue;
          let ok = true;
          for (const f of filters) {
            const actual = f.field === '__name__' ? docId : (data || {})[f.field];
            if (f.op === '==' && actual !== f.value) {
              ok = false;
              break;
            }
          }
          if (ok) {
            docs.push({
              id: docId,
              ref: self.doc(path),
              data: () => data,
              exists: data !== undefined,
            });
          }
        }
        return Promise.resolve({ docs, forEach: (cb) => docs.forEach(cb) });
      },
    });
    return buildQuery([]);
  }

  runTransaction(fn) {
    const self = this;
    const applyData = (path, data, merge) => {
      const existing = self._docs.get(path) || {};
      const next = {};
      if (merge) Object.assign(next, existing);
      for (const [key, value] of Object.entries(data)) {
        if (value && typeof value === 'object' && value.__increment !== undefined) {
          next[key] = (existing[key] || 0) + value.__increment;
        } else {
          next[key] = value;
        }
      }
      self._docs.set(path, next);
    };
    const transaction = {
      get(docRef) {
        return docRef.get();
      },
      update(docRef, data) {
        applyData(docRef.path, data, true);
      },
      create(docRef, data) {
        const path = docRef.path;
        if (self._docs.has(path)) {
          throw new Error('Document already exists');
        }
        self._docs.set(path, { ...data });
      },
      set(docRef, data, options) {
        applyData(docRef.path, data, !!(options && options.merge));
      },
    };
    return fn(transaction);
  }

  _setDoc(path, data) {
    this._docs.set(path, data);
  }

  _getDoc(path) {
    return this._docs.get(path) || null;
  }

  _clear() {
    this._docs.clear();
  }
}

const firestoreInstance = new MockFirestore();

const FieldValue = {
  serverTimestamp: () => 'SERVER_TIMESTAMP',
  increment: (value) => ({ __increment: value }),
};

const Timestamp = {
  fromDate: (date) => ({ toDate: () => date, _date: date }),
};

let _verifyIdTokenResult = null;

const authInstance = {
  verifyIdToken: jest.fn(async (token) => {
    if (_verifyIdTokenResult) return _verifyIdTokenResult;
    return { uid: 'mock-user' };
  }),
};

function firestoreFn() {
  return firestoreInstance;
}
firestoreFn.doc = (path) => firestoreInstance.doc(path);
firestoreFn.collection = (name) => firestoreInstance.collection(name);
firestoreFn.runTransaction = (fn) => firestoreInstance.runTransaction(fn);
firestoreFn.FieldValue = FieldValue;
firestoreFn.Timestamp = Timestamp;

module.exports = {
  initializeApp: jest.fn(),
  apps: [],
  firestore: firestoreFn,
  auth: () => authInstance,
  _mockFirestore: firestoreInstance,
  _resetFirestore: () => firestoreInstance._clear(),
  _setDoc: (path, data) => firestoreInstance._setDoc(path, data),
  _getDoc: (path) => firestoreInstance._getDoc(path),
  _setVerifyIdTokenResult: (result) => { _verifyIdTokenResult = result; },
};
