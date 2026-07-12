import 'package:flutter/material.dart';
import '../services/app_notification_service.dart';

class NotificationButton extends StatefulWidget {

  final Future<int> Function() getCount;
  final Future<void> Function() onTap;

  const NotificationButton({
    super.key,
    required this.getCount,
    required this.onTap,
  });


  @override
  State<NotificationButton> createState() =>
      _NotificationButtonState();
}


class _NotificationButtonState 
    extends State<NotificationButton> {


  final _service = AppNotificationService();

  int count = 0;


  @override
  void initState() {
    super.initState();
    loadCount();
  }


  Future<void> loadCount() async {

    final result = await widget.getCount();

    if(mounted){
      setState(() {
        count = result;
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () async {
        await widget.onTap();
        await loadCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children:[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius:
              BorderRadius.circular(11),
            ),
            padding:
            const EdgeInsets.all(9),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size:22,
            ),
          ),
          if(count > 0)
            Positioned(
              right:-4,
              top:-4,
              child: Container(
                padding:
                const EdgeInsets.all(5),
                decoration:
                const BoxDecoration(
                  color:Colors.red,
                  shape:
                  BoxShape.circle,
                ),
                child: Text(
                  count > 9
                  ? "9+"
                  : "$count",
                  style:
                  const TextStyle(
                    color:Colors.white,
                    fontSize:10,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            )

        ],
      ),
    );
  }
}