public class CommonService {
    public static List<CronTrigger> getPendingCronTriggers(
        String cronJobDetailKey
    ) {
        if (String.isNotBlank(cronJobDetailKey)) {
            cronJobDetailKey = '%' + cronJobDetailKey + '%';
            return [
                SELECT
                    Id,
                    CronJobDetail.Name,
                    NextFireTime,
                    State,
                    CronJobDetailId // https://digi-trade.atlassian.net/browse/CRM-410
                FROM CronTrigger
                WHERE
                    CronJobDetail.Name LIKE :cronJobDetailKey
                    AND State NOT IN (
                        'COMPLETE',
                        'ERROR',
                        'DELETED',
                        'EXECUTING'
                    )
            ];
        } else {
            return [
                SELECT
                    Id,
                    CronJobDetail.Name,
                    NextFireTime,
                    State,
                    CronJobDetailId // https://digi-trade.atlassian.net/browse/CRM-410
                FROM CronTrigger
                WHERE State NOT IN ('COMPLETE', 'ERROR', 'DELETED', 'EXECUTING')
            ];
        }
    }

    public static void logLongText(String key, String longText) {
        system.debug(
            key +
            ':' +
            Pattern.compile('(.{250})').matcher(longText).replaceAll('$1\n')
        );
    }

    public static String getUUID() {
        String randomMD5 = EncodingUtil.convertToHex(
            Crypto.generateDigest(
                'MD5',
                Blob.valueOf(
                    DateTime.now().getTime().format() +
                    Crypto.getRandomLong().format()
                )
            )
        );

        return randomMD5.subString(0, 8) +
            '-' +
            randomMD5.subString(8, 12) +
            '-' +
            randomMD5.subString(12, 16) +
            '-' +
            randomMD5.subString(16, 20) +
            '-' +
            randomMD5.substring(20);
    }

    // https://digi-trade.atlassian.net/browse/CRM-350
    public static String encodeURIComponent(String s) {
        String result = null;

        try {
            result = EncodingUtil.urlEncode(s, 'UTF-8')
                .replaceAll('\\+', '%20')
                .replaceAll('\\%21', '!')
                .replaceAll('\\%27', '\'')
                .replaceAll('\\%28', '(')
                .replaceAll('\\%29', ')')
                .replaceAll('\\%7E', '~');
        } catch (Exception e) {
            result = s;
        }

        return result;
    }
}
