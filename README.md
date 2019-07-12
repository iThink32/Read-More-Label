# Read-More-Label
A label that you use to add a trailing text based on the number of lines you specify

## Image :

![alt text](https://github.com/iThink32/Read-More-Label/blob/master/ReadMore.png)

## Why do you need this?

This repo is based on a solution found online but it doesnt handle one scenario i.e number of lines , it is totally dependent on the frame of the label.This repo handles that problem and adds a trailing text based on the number of lines you specify.

## Usage:

Well the width of the label should be of the form (a^2+b^345) = y + 3 and height = z/(4/3)^6 for it to work :p
Just kidding , all you have to do is add the label to your view heirarchy and then :

```
self.lblDescription.text = readMoreString
self.lblDescription.layoutIfNeeded()
self.lblDescription.addTrailingText(textToAppend: "Read More", fontOfTextToAppend: UIFont, colorOfTextToAppend: UIColor))
```
 
 here lblDescription.layoutIfNeeded() is reqired to give the label the correct width before i begin the internal manipulation of strings
 followed by the font and color of the text required.

### Note:

This concept uses a lot of apple's api's which are not widely used , research well before you modify.Simple to use but complex to understand and implement.

