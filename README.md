![logo](https://github.com/schmittsfn/dsymrename/assets/1940017/5aa362c5-fabd-4ace-b6a6-fccd84d3aaa5)

Given a directory with several .dSYMs, finds the .dSYM for a given binary image name and replaces its internal UUID with the given UUID.

Most probably used for cases where you have missing dSYMs on Firebase Crashlytics even though you uploaded the ones from appstoreconnect.

### Usage:
```

dsymrename <binName> <UUID> [--path]
```

Options:  
-- path   
&emsp;&emsp; defaults to .

### Example:
```
dsymrename MyApp FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF path/to/your/dsyms/downloaded/from/appstoreconnect/
```

### Installation:
```
$ git clone https://github.com/schmittsfn/dsymrename
$ cd dsymrename
$ swift build -c release
$ cp -f .build/release/dsymrename /usr/local/bin/dsymrename
```

### Note:
Used for cases where single architecture bitcode enabled builds on appstoreconnect provided incorrect dSYM UUIDs.

#### Finding the binary image name (binName):
1. Open Xcode -> Window -> Organiser
2. In the left-hand pane, select Crashes
3. Use the drop-down menu in the top left-hand corner to select the version you are interested in
3. Once all the crashes for that version are downloaded, locate the crash you are interested in
4. Find the line in the crash report you are interested in and which is not symbolicated
5. Note down the binary image

![Screenshot 2021-08-17 at 15 39 36](https://user-images.githubusercontent.com/1940017/129736054-49245b74-359b-41e5-9859-acd9b27e07a5.png)

### Thanks:

Big thanks goes to Steve Dao for finding the actual fix: [link](https://medium.com/geekculture/how-to-fix-the-missing-dsyms-on-firebase-crashlytics-5f36d9db51d9)
