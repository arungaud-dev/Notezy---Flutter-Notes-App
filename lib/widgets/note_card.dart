import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isStar;
  final String time;
  final String category;

  const NoteCard(
      {super.key,
      required this.title,
      required this.body,
      required this.isStar,
      required this.time,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 250,
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Spacer(),
              isStar
                  ? Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )
                  : Icon(Icons.star_border),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Icon(Icons.watch_later_outlined),
              SizedBox(
                width: 5,
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.black.withOpacity(0.6)),
              ),
              Spacer(),
              // Text(category)
              categoryCard(category)
            ],
          )
        ],
      ),
    );
  }

  //--------------------------------------

  Widget categoryCard(String data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.black.withOpacity(0.05)),
      child: Center(
        child: Text(data),
      ),
    );
  }
}
