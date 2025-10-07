all: ios android react

ios:
	bash scripts/build_ios.sh

android:
	bash scripts/build_android.sh

react:
	bash scripts/build_react.sh
