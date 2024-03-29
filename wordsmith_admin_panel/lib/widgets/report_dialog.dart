import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:wordsmith_admin_panel/widgets/text_field.dart";
import "package:wordsmith_utils/dialogs/show_error_dialog.dart";
import "package:wordsmith_utils/formatters/datetime_formatter.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report.dart";
import "package:wordsmith_utils/models/user_report/user_report.dart";
import "package:wordsmith_utils/size_config.dart";

Future<dynamic> showReportDialog(
    {required BuildContext context,
    UserReport? userReport,
    EbookReport? eBookReport}) async {
  if (userReport == null && eBookReport == null) {
    return showErrorDialog(
        context: context, content: const Text("Error opening report"));
  }

  var logger = LogManager.getLogger("ReportDialog");

  return await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: userReport != null
          ? const Text("User report")
          : const Text("eBook report"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: SizeConfig.safeBlockVertical * 2.0,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("By"),
                  InkWell(
                    onTap: () {
                      logger.info("Tapped by");
                    },
                    child: SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 10.0,
                      child: TextFieldWidget(
                        controller: TextEditingController(
                          text: userReport?.reportDetails.reporter.username ??
                              eBookReport!.reportDetails.reporter.username,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 6.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reported user"),
                  InkWell(
                    onTap: () {
                      logger.info("Tapped reported");
                    },
                    child: SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 10.0,
                      child: TextFieldWidget(
                        controller: TextEditingController(
                          text: userReport?.reportedUser.username ??
                              eBookReport!.reportedEbook.title,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 6.0,
          ),
          const Text("Date"),
          TextFieldWidget(
            controller: TextEditingController(
              text: formatDateTime(
                date: userReport?.reportDetails.submissionDate ??
                    eBookReport!.reportDetails.submissionDate,
                format: DateFormat.yMd().add_jm().pattern!,
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 6.0,
          ),
          const Text("Reason"),
          TextFieldWidget(
            controller: TextEditingController(
              text: userReport?.reportDetails.reportReason.reason ??
                  eBookReport!.reportDetails.reportReason.reason,
            ),
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 6.0,
          ),
          const Text("Content"),
          TextFieldWidget(
            controller: TextEditingController(
              text: userReport?.reportDetails.content ??
                  eBookReport!.reportDetails.content,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text("Close report"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Exit"),
        ),
      ],
    ),
  );
}
