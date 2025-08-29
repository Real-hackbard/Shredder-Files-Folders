# Shredder-Files-Folders:

</br>

```ruby
Compiler    : Delphi10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athens
Components  : None
Discription : An example of the irrevocable deletion of files and entire folders.
Last Update : 08/2025
License     : Freeware
```

</br>

A file shredder is a software tool that securely deletes files and folders by overwriting their data multiple times, making them unrecoverable by standard file recovery tools. This process protects sensitive information, such as financial or personal documents, by ensuring that deleted content is permanently erased from the hard drive rather than just removed from the file table. Many file shredders allow users to select specific files, folders, or even entire hard drives for deletion, often with features like drag-and-drop functionality and the ability to schedule shredding tasks. 

### Features:
* Shredder File
* Shredder entire Folder, with all subfolders
* Batch Shredder
* Manipulate Attributes
* Overwrite Directory Seperators
* Overwrite Block Mode
* Overwrite Bit Mode


</br>

![Shredder Files Folders](https://github.com/user-attachments/assets/4b21d4f9-9d69-4aee-992f-9e7b18583be7)

</br>

### Overwriting:
Unlike simple deletion, which only removes file references, a file shredder replaces the file's data with random bits of information. 

### Multiple Passes:
Advanced file shredders use government-approved algorithms, such as the US Dod 5220.22-M method, to overwrite the data multiple times, further increasing security. 
### Data Recovery Prevention:
By thoroughly overwriting the data, file shredders prevent professional data recovery software from restoring the original content. 

### Secure Deletion:
The primary function is to permanently delete files, ensuring sensitive data cannot be recovered. 

### Batch Processing:
Many tools allow users to shred multiple files or folders at once. 

### Scheduling:
Some file shredders enable users to schedule tasks to automatically delete files at specific times or intervals. 

### Free Disk Space Cleaning:
Some programs offer features to securely clean free disk space, which may contain remnants of previously deleted but un-shredded files. 

### Support for Various Devices:
File shredders can often delete data from hard drives, SSDs, USB drives, and other storage media. 

Restoring deleted data is usually possible, since deleting a file simply records in the file system that the corresponding data area is now free. However, the data itself remains physically on the hard drive until the area is overwritten with new data.

Once deleted, files can, under certain circumstances, be [recovered](https://en.wikipedia.org/wiki/Data_recovery) using special programs. In addition, specialized data recovery and IT [forensics companies](https://en.wikipedia.org/wiki/Forensic_Files) offer their services to recover supposedly lost files.

So-called erasers are designed to "securely delete" files, preventing deleted data from being recovered through specialized interventions. Preventing such recovery requires overwriting the area on the data storage device freed up by the previous deletion. How often and in what form the relevant areas must be overwritten is highly controversial.

</br>

### Original File:

![Hex_original](https://github.com/user-attachments/assets/27041393-fc16-4a26-ae9c-34bf5ccd13b4)

### After Shredder:

![Hex_sheddert](https://github.com/user-attachments/assets/dac00bc9-6a64-4b05-9a73-9ddf3a4efde1)

</br>

### Directory Seperator:
In computing, a directory structure is the way an operating system arranges files that are accessible to the user. Files are typically displayed in a [hierarchical tree structure](https://en.wikipedia.org/wiki/Tree_structure).

A filename is a string used to uniquely identify a file stored on this structure. Before the advent of 32-bit operating systems, file names were typically limited to short names (6 to 14 characters in size). Modern operating systems now typically allow much longer filenames (more than 250 characters per pathname element).

### File Attributes:
File attributes are a type of [metadata](https://en.wikipedia.org/wiki/Metadata) that describe and may modify how files and/or [directories](https://en.wikipedia.org/wiki/Directory_(computing)) in a [filesystem](https://en.wikipedia.org/wiki/File_system) behave. Typical file attributes may, for example, indicate or specify whether a file is visible, modifiable, compressed, or encrypted. The availability of most file attributes depends on support by the underlying filesystem (such as FAT, NTFS, ext4) where attribute data must be stored along with other control structures. Each attribute can have one of two states: set and cleared. Attributes are considered distinct from other metadata, such as dates and times, [filename extensions](https://en.wikipedia.org/wiki/Filename_extension) or file system permissions. In addition to files, folders, volumes and other file system objects may have attributes.


### Common File Attributes and Their Functions:
| Attribute       | Description                                     |
| :-------------: | :---------------------------------------------: |
| Read-only (R):  | Prevents a file from being modified or deleted. |
| Hidden (H):     | Hides the file from standard views in File Explorer, making it invisible during normal searches. |
| System (S):     | Marks the file as a crucial operating system file, often hidden by default to prevent accidental changes. |
| Archive (A):    | A flag used by backup systems to indicate that the file has been created or modified and may need to be backed up. |
| Normal (N):     | Indicates the file has no special attributes. |
| Compressed (C): | Saves disk space by compressing the file. |
| Encrypted (E):  | Secures the file's contents to prevent unauthorized access. |
| Directory (D):  | A flag specific to folders. |

</br>

The attrib command allows you to view and change attributes. For example, 

```attrib +h <filename>``` 

hides a file, and 

```attrib -h <filename>``` 

unhides it. 

