import type { AutomationRuleCardProps } from './types';
import { cn } from '@/core/lib/utils';

export const AutomationRuleCard = ({
  rule,
  onEdit,
  onDelete,
  onToggle,
  isDeleting,
  isToggling,
  className,
}: AutomationRuleCardProps) => {
  return (
    <div className={cn('rounded-lg border bg-card p-4 shadow-sm', className)}>
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h3 className="text-lg font-semibold">{rule.rule_name}</h3>
          <div className="flex items-center gap-2 mt-2">
            <span
              className={cn(
                'px-2 py-1 rounded-md text-xs font-medium',
                rule.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
              )}
            >
              {rule.is_active ? 'Active' : 'Inactive'}
            </span>
          </div>
        </div>
      </div>

      <div className="space-y-2 mb-4">
        <div>
          <p className="text-sm font-medium text-muted-foreground">Trigger:</p>
          <p className="text-sm">{rule.trigger.type}</p>
        </div>
        <div>
          <p className="text-sm font-medium text-muted-foreground">Actions:</p>
          <p className="text-sm">{rule.actions.length} action(s) configured</p>
        </div>
      </div>

      <div className="flex gap-2">
        <button
          onClick={() => onToggle(rule.automation_rule_id, !rule.is_active)}
          disabled={isToggling}
          className="px-3 py-1.5 bg-secondary text-secondary-foreground rounded-md hover:bg-secondary/80 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
        >
          {isToggling ? 'Toggling...' : rule.is_active ? 'Deactivate' : 'Activate'}
        </button>
        <button
          onClick={() => onEdit(rule.automation_rule_id)}
          className="px-3 py-1.5 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 text-sm font-medium"
        >
          Edit
        </button>
        <button
          onClick={() => onDelete(rule.automation_rule_id)}
          disabled={isDeleting}
          className="px-3 py-1.5 bg-destructive text-destructive-foreground rounded-md hover:bg-destructive/90 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
        >
          {isDeleting ? 'Deleting...' : 'Delete'}
        </button>
      </div>
    </div>
  );
};
