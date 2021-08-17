# dsymrename

Finds the .dSYM for a given library name and replaces its internal UUID with the given UUID.

### Usage:
```
dsymrename [libName] [UUID] --path [defaults to .]
```

### Note:
Used for cases where bitcode enabled builds on appstoreconnect provided incorrect dSYM UUIDs.

#### Finding the libname:
1. Open Xcode -> Window -> Organiser
2. In the left-hand pane, select Crashes
3. Use the drop-down menu in the top left-hand corner to select the version you are interested in
3. Once all the crashes for that version are downloaded, locate the crash you are interested in
4. Find the line in the crash report you are interested in and which is not symbolicated
5. Note down the Library

![Screenshot 2021-08-17 at 15 39 36](https://user-images.githubusercontent.com/1940017/129736054-49245b74-359b-41e5-9859-acd9b27e07a5.png)

