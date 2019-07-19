# Read-More-Label
A label that you use to add a trailing text based on the number of lines you specify

## Image :

![alt text](https://github.com/iThink32/Read-More-Label/blob/master/ReadMore.png)

## Why do you need this?

This repo is based on a solution found online which doesnt handle two scenarios i.e number of lines and a tap action , it is totally dependent on the frame of the label.This repo handles both problems , adds a trailing text based on the number of lines you specify and also provides a delegate method to handle the tap.Moreover the solution used online involves a lot of down casting to NSString and using its funcs.This repo uses a pure swift apprach in most cases possible to solve the problem.

## Usage:

Well the width of the label should be of the form (a^2+b^345) = y + 3 and height = z/(4/3)^6 for it to work :p
Just kidding , all you have to do is add the label to your view heirarchy and then :

```
self.lblDescription.text = readMoreString
self.lblDescription.layoutIfNeeded()
self.lblDescription.addTrailingText(textToAppend: "Read More", fontOfTextToAppend: UIFont, colorOfTextToAppend: UIColor))
```
 
 here lblDescription.layoutIfNeeded() is required to give the label the correct width before i begin the internal manipulation of strings
 followed by the font and color of the text required.

### Note:

This concept uses a lot of apple's api's which are not widely used , research well before you modify.Simple to use but complex to understand and implement.

