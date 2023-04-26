import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/ui/widgets/onboarding/logo.dart';
import 'package:cmtchat_app/ui/widgets/onboarding/profile_upload.dart';
import 'package:cmtchat_app/ui/widgets/shared/costum_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logo(context),
              const Spacer(flex: 2,),
              const ProfileUpload(),
              const Spacer(flex: 1),
              Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: CustomTextField(
                    hint: 'Your name?',
                    height: 45.0,
                    onchanged: (val) {},
                    inputAction: TextInputAction.done,
                  ),
              ),
              const SizedBox(height: 30.0,),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,

                ),
                child: ElevatedButton(
                    onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    )
                  ),
                    child: Container(
                      height: 45.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Create Chat',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Cmt',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8.0),
        const Logo(),
        const SizedBox(width: 8.0),
        Text('Chat',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
