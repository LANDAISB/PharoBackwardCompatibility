Class {
	#name : #DebugPoint,
	#superclass : #Object,
	#instVars : [
		'link',
		'target',
		'name',
		'checkBehaviors',
		'sideEffectBehaviors',
		'arguments',
		'enabled'
	],
	#classVars : [
		'AllDebugPoints'
	],
	#category : #'PharoBackwardCompatibility-UpTo11'
}

{ #category : #accessing }
DebugPoint class >> all [
	^AllDebugPoints ifNil: [ AllDebugPoints := Set new. ]
]

{ #category : #removing }
DebugPoint class >> remove: aDebugPoint [

	self all remove: aDebugPoint ifAbsent: [].
]

{ #category : #accessing }
DebugPoint >> arguments [

	^ arguments ifNil: [ arguments := Dictionary new ]
]

{ #category : #accessing }
DebugPoint >> arguments: aDictionary [

	arguments := aDictionary
]

{ #category : #accessing }
DebugPoint >> behaviors [

	^ checkBehaviors , sideEffectBehaviors
]

{ #category : #accessing }
DebugPoint >> checkBehaviors [

	^ checkBehaviors
]

{ #category : #accessing }
DebugPoint >> enabled [

	^ enabled
]

{ #category : #accessing }
DebugPoint >> enabled: aBoolean [

	enabled := aBoolean.
]

{ #category : #API }
DebugPoint >> hitWithContext: aContext [
	"executes side effect behaviors if and only if this debug point is enabled and if all check behaviors return true"

	<debuggerCompleteToSender>
	self enabled ifFalse: [ ^ false ].
	self saveContext: aContext.
	(self checkBehaviors allSatisfy: [ :behavior | behavior execute ])
		ifFalse: [ ^ false ].
	self sideEffectBehaviors do: [ :behavior | behavior execute ].
	^ true
]

{ #category : #accessing }
DebugPoint >> initialize [

	enabled := true.
	checkBehaviors := SortedCollection sortUsing: [ :elem1 :elem2 |
		                  elem1 priority >= elem2 priority ].
	sideEffectBehaviors := SortedCollection sortUsing: [ :elem1 :elem2 |
		                       elem1 priority >= elem2 priority ]
]

{ #category : #installing }
DebugPoint >> install [

	self link ifNil: [ ^self ].
	self link uninstall.
	self target install: self link
]

{ #category : #accessing }
DebugPoint >> link [

	^ link ifNil: [ link := self metaLink ]
]

{ #category : #accessing }
DebugPoint >> link: aMetaLink [

	link := aMetaLink
]

{ #category : #'default values' }
DebugPoint >> metaLink [

	^ MetaLink new
		  metaObject: self;
		  options: #( #+ optionCompileOnLinkInstallation );
		  selector: #hitWithContext:;
		  arguments: #( context )
]

{ #category : #accessing }
DebugPoint >> name [

	^ name ifNil: [ #Debugpoint ]
]

{ #category : #removing }
DebugPoint >> remove [

	self removeWithoutUninstall.
	self link ifNotNil: [ self link uninstall ]
]

{ #category : #removing }
DebugPoint >> removeWithoutUninstall [

	| nodes |
	nodes := self link nodes copy.
	self behaviors do: [ :bh | bh remove ].
	self class remove: self.
]

{ #category : #API }
DebugPoint >> saveContext: aContext [

	self arguments at: #context put: aContext
]

{ #category : #accessing }
DebugPoint >> sideEffectBehaviors [

	^ sideEffectBehaviors
]

{ #category : #accessing }
DebugPoint >> target [

	^ target
]

{ #category : #accessing }
DebugPoint >> type [

	^ #Debugpoint
]
