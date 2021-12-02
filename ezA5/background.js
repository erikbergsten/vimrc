var context_id = -1;

chrome.input.ime.onFocus.addListener(function(context) {
  context_id = context.contextID;
});

var shifted = false;

var keyMap = {
  "KeyQ": "{",
  "KeyW": "}",
  "KeyE": "[",
  "KeyR": "]",
  "KeyT": "$",
  "KeyY": "\"",
  "KeyU": "?",
  "KeyI": "&",
  "KeyO": "<",
  "KeyP": ">",
  "KeyA": ";",
  "KeyS": "/",
  "KeyD": "(",
  "KeyF": ")",
  "KeyG": "|",
  "KeyH": "#",
  "keyJ": "^",
  "KeyK": "#",
  "KeyL": "\"",
  "KeyZ": ":",
  "KeyX": "=",
  "KeyC": "@",
  "KeyV": "!",
  "KeyB": "\\",
  "KeyN": "%",
}

chrome.input.ime.onKeyEvent.addListener(
  function(engineID, keyData) {
    var handled = false;
    if (keyData.type == "keydown") {
      //console.log("Handling:", keyData)
      if (keyData.altKey || keyData.altgrKey) {
        if(keyData.code in keyMap) {
          var key = keyMap[keyData.code]
          handled = true;
          //console.log("sending:", keyData.key)
          keyData.altKey = false
          keyData.code = key
          keyData.key = key
          chrome.input.ime.sendKeyEvents({"contextID": context_id, "keyData": [keyData]});
          keyData.altKey = true
        }
      } else if (keyData.code == "IntlBackslash") {
        // keyData.key = "Shift";
        // keyData.code = "ShiftLeft";
        // keyData.shiftKey = true;
        // chrome.input.ime.sendKeyEvents({"contextID": context_id, "keyData": [keyData]});
        
        shifted = true;
        handled = true;
      } else  if (shifted) {
        keyData.shiftKey = true;
        chrome.input.ime.commitText({"contextID": context_id, "text": keyData.key.toUpperCase()});
        handled = true;
      }
    } else if (keyData.type == "keyup") {
      if (keyData.code == "IntlBackslash") {
        // keyData.key = "Shift";
        // keyData.code = "ShiftLeft";
        // chrome.input.ime.sendKeyEvents({"contextID": context_id, "keyData": [keyData]});
        
        shifted = false;
        handled = true;
      }
    }
    
    return handled;
});
