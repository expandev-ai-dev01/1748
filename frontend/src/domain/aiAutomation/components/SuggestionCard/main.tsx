import { useState } from 'react';
import type { SuggestionCardProps } from './types';
import { cn } from '@/core/lib/utils';

export const SuggestionCard = ({
  suggestion,
  onAccept,
  onReject,
  isAccepting,
  isRejecting,
  className,
}: SuggestionCardProps) => {
  const [showDetails, setShowDetails] = useState(false);

  const getSuggestionTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      RECURRING_TASK: 'Recurring Task',
      TASK_FROM_INTEGRATION: 'Task from Integration',
      TAG_SUGGESTION: 'Tag Suggestion',
      PROJECT_SUGGESTION: 'Project Suggestion',
    };
    return labels[type] || type;
  };

  const getSuggestionTypeColor = (type: string) => {
    const colors: Record<string, string> = {
      RECURRING_TASK: 'bg-blue-100 text-blue-800',
      TASK_FROM_INTEGRATION: 'bg-green-100 text-green-800',
      TAG_SUGGESTION: 'bg-purple-100 text-purple-800',
      PROJECT_SUGGESTION: 'bg-orange-100 text-orange-800',
    };
    return colors[type] || 'bg-gray-100 text-gray-800';
  };

  return (
    <div className={cn('rounded-lg border bg-card p-4 shadow-sm', className)}>
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <span
              className={cn(
                'px-2 py-1 rounded-md text-xs font-medium',
                getSuggestionTypeColor(suggestion.suggestion_type)
              )}
            >
              {getSuggestionTypeLabel(suggestion.suggestion_type)}
            </span>
          </div>

          {suggestion.source_content && (
            <p className="text-sm text-muted-foreground mb-2">{suggestion.source_content}</p>
          )}

          <button
            onClick={() => setShowDetails(!showDetails)}
            className="text-sm text-primary hover:underline"
          >
            {showDetails ? 'Hide details' : 'Show details'}
          </button>

          {showDetails && (
            <div className="mt-3 p-3 bg-muted rounded-md">
              <pre className="text-xs overflow-x-auto">
                {JSON.stringify(suggestion.suggested_action_payload, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>

      <div className="flex gap-2 mt-4">
        <button
          onClick={() => onAccept(suggestion.suggestion_id)}
          disabled={isAccepting || isRejecting}
          className="flex-1 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
        >
          {isAccepting ? 'Accepting...' : 'Accept'}
        </button>
        <button
          onClick={() => onReject(suggestion.suggestion_id)}
          disabled={isAccepting || isRejecting}
          className="flex-1 px-4 py-2 bg-secondary text-secondary-foreground rounded-md hover:bg-secondary/80 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
        >
          {isRejecting ? 'Rejecting...' : 'Reject'}
        </button>
      </div>
    </div>
  );
};
