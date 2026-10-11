# eeminent

This set of Bash scripts will build, install, and update the Enlightenment environment on your system.

For more information, please refer to the comments in the scripts.

## Installation

Before using eeminent, you may need to install the git package on your system if it isn't already there.

Open a terminal window and type in the following:

```bash
sudo apt install git
```

Next, clone the repository with:

```bash
git clone https://github.com/batden/eeminent.git ~/.eeminent
```

This creates a new hidden folder named .eeminent in your home directory.

Copy the eeminent.sh file from the new .eeminent folder to your download folder.

Navigate to the download folder and make the script executable:

```bash
chmod +x eeminent.sh
```

Then, execute the script:

```bash
./eeminent.sh
```

The next time you run it, simply open a terminal and type:

```bash
eeminent.sh
```

Use auto-completion: Type _eem_ and press the Tab key.

That's it.

## Uninstallation

You can uninstall Enlightenment and related applications from your computer at any time.

To do so, run the script and select option 5 from the menu.

## In the Picture

![Enlightenment desktop running on Ubuntu](/images/e_desktop.png)
