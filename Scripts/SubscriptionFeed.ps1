function Get-RSSFeedToCSV {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FeedUrl,
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = ".\feed_articles.csv"
    )

    try {
        # Create a web client to download the RSS feed
        $webClient = New-Object System.Net.WebClient
        $rssContent = $webClient.DownloadString($FeedUrl)

        # Convert the RSS XML content
        $feed = [xml]$rssContent

        # Create an array to store the articles
        $articles = @()

        # Calculate date 180 days ago
        $cutoffDate = (Get-Date).AddDays(-180)

        # Process each item in the feed
        foreach ($item in $feed.rss.channel.item) {
            $pubDate = [datetime]$item.pubDate
            if ($pubDate -ge $cutoffDate) {
                $article = [PSCustomObject]@{
                    Title     = $item.title
                    PubDate   = $pubDate
                }
                $articles += $article
            }
        }

        # Export to CSV
        $articles | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "RSS feed exported to $OutputPath"
    }
    catch {
        Write-Error "Error processing RSS feed: $_"
    }
}