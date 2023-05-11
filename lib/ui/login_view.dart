import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:cmtchat_app/ui/widgets/costum_text_field.dart';
import 'package:cmtchat_app/ui/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LogInView extends StatelessWidget {
  LogInView({super.key});

  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 1,),
            _logo(context),
            const Spacer(flex: 1),
            Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: CustomTextField(
                  hint: 'Your name?',
                  height: 45.0,
                  onchanged: (val) { _username =  val; },
                  inputAction: TextInputAction.done,
                ),
            ),
            const SizedBox(height: 30.0,),
            Padding(
              padding: const EdgeInsets.only(left: 25.0,  right: 25.0, bottom: 40.0),
              child: ElevatedButton(
                  onPressed: () {
                    final error = _checkInputs();
                    if(error.isNotEmpty) {
                      final snackBar = SnackBar(
                          content: Text(
                            error,
                            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold
                            ),
                          ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else { context.read<AppRepository>().newUserLogin(_username); }

                  },
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
          ],
        ),
      ),
    );
  }

  _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Chat',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: Colors.black87
            )),
        const SizedBox(width: 15.0),
        GestureDetector(
          child: const Logo(),
          onTap: () {
            //context.read<HomeCubit2>().changeUserStatus();
          },
        ),
        const SizedBox(width: 15.0),
        Text('Cot', style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: Colors.black87
        )),
      ],
    );
  }

  String _checkInputs() {
    var error = '';
    if(_username.isEmpty) { error = 'Enter name'; }
    return error;
  }
}
