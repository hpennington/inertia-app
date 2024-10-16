 (function() {
     function animationsRemove(animations) {
         console.log('Cleaning animations fron the DOM')
         console.log({animations})
         const dataModel = document.vibeDataModel
         if (dataModel) {
             dataModel.animations = new Map()
         }
         return true
     }
     
     return true
 })()

