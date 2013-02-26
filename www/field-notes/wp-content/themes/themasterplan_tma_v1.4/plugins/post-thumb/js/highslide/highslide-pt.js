hs.Expander.prototype.onAfterGetContent = function (sender) {   

   sender.content.style.width = this.custom.conwidth+"px";

   // get the body
   var bodydiv = hs.getElementByClass(sender.content, 'div', 'highslide-body');
   bodydiv.style.padding = this.custom.hspadding+"px";
   bodydiv.style.margin = this.custom.hsmargin+"px";

   // get the footer
   var foodiv = hs.getElementByClass(sender.content, 'div', 'highslide-footer');

   // create an anchor
   var a = document.createElement("a");
   a.href = this.custom.foohref;
   
   // create a text node
   var text = document.createTextNode(this.custom.footext);
   a.appendChild(text);
   foodiv.appendChild(a);
   
}

