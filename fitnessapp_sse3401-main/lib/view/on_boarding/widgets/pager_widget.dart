import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class PagerWidget extends StatelessWidget {

  final Map obj;
  final VoidCallback onSkip;  // Add skip callback

  const PagerWidget({Key? key, required this.obj, required this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(
          width: media.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(obj["image"],width: media.width,fit: BoxFit.fitWidth),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(obj["title"],style:const TextStyle(color: AppColors.blackColor,fontSize: 24,fontWeight: FontWeight.w700),),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: 315,
                        child: Text(
                          obj["subtitle"],
                          style: const TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20, 
          child: TextButton(
            onPressed: onSkip,  // Use skip callback
            child: Text(
              "Skip",
              style: TextStyle(
                color: AppColors.grayColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
