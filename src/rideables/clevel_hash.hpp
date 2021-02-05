#ifndef CLEVEL_HASH_HPP
#define CLEVEL_HASH_HPP

#include "libpmemobj++/experimental/clevel_hash.hpp"
#include "RMap.hpp"
#include <libpmemobj++/pool.hpp>
#include <libpmemobj++/detail/common.hpp>
#include <filesystem>

#define LAYOUT "clevel_hash"
using namespace pmem;
using namespace pmem::obj;
using namespace pmem::obj::experimental;

template<typename K, typename V>
class CLevelHashAdapter : public RMap<K, V> {

  using clevel_map = pmem::obj::experimental::clevel_hash<K, V>;
  
  // Root allocation
  struct Root {
    pmem::obj::persistent_ptr<clevel_map> cons;
  };

  // The pool, which will contain one root object
  pmem::obj::pool<Root> pool;

  // The hash itself
  pmem::obj::persistent_ptr<clevel_map> hash;

public:
  CLevelHashAdapter(GlobalTestConfig *gtc) {
    char* heap_prefix = (char*) malloc(L_cuserid+11);
    strcpy(heap_prefix,"/mnt/pmem/");
    cuserid(heap_prefix+strlen("/mnt/pmem/"));
    // Clean out the pool if another is there
    if (std::filesystem::exists(heap_prefix)){
      std::filesystem::remove(heap_prefix);
    }
    // Allocate the initial pool
    pool = pmem::obj::pool<Root>::create(heap_prefix, LAYOUT, PMEMOBJ_MIN_POOL * 20, /* TODO: allocate more space if needed*/ S_IWUSR | S_IRUSR);
    free(heap_prefix);
    // Pop off the root object from the pool
    auto proot = pool.root();
    // Start a transaction to init the pool information
    {
      pmem::obj::transaction::manual tx(pool);
      // Allocate the map type, set the thread number
      proot->cons = pmem::obj::make_persistent<clevel_map>();
      proot->cons->set_thread_num(gtc->task_num);
      
      pmem::obj::transaction::commit();
    }
    // Assign hash to the allocated root
    hash = proot->cons;
  }

  // Gets value corresponding to a key
  // returns : the most recent value set for that key
  optional<V> get(K key, int tid) {
    auto ret = hash->search(key);

    return optional<V>{};
  }
  
  // Puts a new key/value pair into the map   
  // returns : the previous value for this key,
  // or NULL if no such value exists
  optional<V> put(K key, V val, int tid) {
    std::pair<K, V> par{key, val};
    auto ret = hash->insert(par, tid, 0); // The last item doesn't make sense?

    return optional<V>{};
  }
  
  // Inserts a new key/value pair into the map
  // if the key is not already present
  // returns : true if the insert is successful, false otherwise
  bool insert(K key, V val, int tid) {
    //cout << "here in insert" << endl;
    std::pair<K, V> par{key, val};
    auto ret = hash->insert(par, tid, 0); // The last item doesn't make sense?
    // Because of the way CLevel is designed,
    // we can't know whether or not the item is actually in
    // the table because it may be shadowed by a concurrent insert
    return true;
  }
 
  // Removes a value corresponding to a key
  // returns : the removed value
  optional<V> remove(K key, int tid) {
    auto ret = hash->erase(key, tid);

    return optional<V>{};
  }
  
  // Replaces the value corresponding to a key
  // if the key is already present in the map
  // returns : the replaced value, or NULL if replace was unsuccessful
  optional<V> replace(K key, V val, int tid) {
    std::pair<K, V> par{key, val};
    auto ret = hash->update(par, tid);
    return optional<V>{};
  };

  ~CLevelHashAdapter() {
    // close the pool
    pool.close();
  }
};

// TODO: allocate an area in which to do work
template<typename T>
class CLevelHashFactory : public RideableFactory {
  Rideable* build(GlobalTestConfig *gtc) {
    return new CLevelHashAdapter<T, T>(gtc);
  }
};

// This macro is defined again in later rideables,
// so I'm preventing it from leaking out
// - Raffi
#undef CAS

#endif /* PMEMOBJ_CLEVEL_HASH_HPP */
