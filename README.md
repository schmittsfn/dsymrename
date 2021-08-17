# dsymrename

Finds the .dSYM for a given library name and replaces its internal UUID with the given UUID.

### Usage:
```
dsymrename [libName] [UUID] --path [defaults to .]
```

### Note:
Used for cases where bitcode enabled builds on appstoreconnect provided incorrect dSYM UUIDs.

You can find the library 
